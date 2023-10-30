#!@RUNSHELL@
#
#   addep.sh - Add dependencies through ELF files
#

[[ -n "$LIBMAKEPKG_TIDY_ADDEP_SH" ]] && return
LIBMAKEPKG_TIDY_ADDEP_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('addep')
tidy_remove+=('tidy_addep')

_do_dup() {
	local _f="${1:0:3}"
	local _args
	touch ${_f}
	for _args in {ld-linux*so,ld-musl*so,libc.so,libm.so,libresolv.so,lib*_debug.so,libsystemd-shared-*.so}
	do
		sed -i "/^${_args/\*/.*}/d" ${_f}
	done

	case "${_f}" in
		pro)
			if [ "$NOADD_PRO" ]; then
				for _args in ${NOADD_PRO[@]}; do
					sed -i "/^${_args}\$/d;/^${_args}=\(.*\)/d" ${_f}
				done
			fi
			;;
		dep)
			if [ "$NOADD_DEP" ]; then
				for _args in ${NOADD_DEP[@]}; do
					sed -i "/^${_args}\$/d;/^${_args}=\(.*\)/d" ${_f}
				done
			fi
			;;
	esac

	sort -u ${_f} > $1
	echo "$(<$1)"
}

_add_provides() {
	local _F _dir
	rm -f "${addep_tmp}/pro"

	_fd_libpro()
	{
		if LC_ALL=C readelf -h "$1" 2>/dev/null | grep -q '.*Type:.*DYN (Shared object file).*'; then
			local sofile=$(LC_ALL=C readelf -d "$1" 2>/dev/null | sed -n 's/.*Library soname: \[\(.*\)\].*/\1/p')
			[[ -n "$sofile" ]] || continue

			local soarch=$(LC_ALL=C readelf -h "$1" | sed -n 's/.*Class.*ELF\(32\|64\)/\1/p')
			local sof="${sofile/\.so\.*/.so}"
			local soversion="${sofile##*\.so\.}"

			echo "${sof}=${soversion}-${soarch}" >> "${addep_tmp}/pro"
		fi
	}

	if [[ -n "${provides[@]}" ]]; then
		for i in ${provides[@]}; do echo "$i" >> "${addep_tmp}/pro"; done
	fi

	for _dir in usr/lib{,32}; do
		[ -d "$_dir" ] || continue
		for _F in `find $_dir -maxdepth 1 -name \*.so -exec basename {} \;` \
			`find $_dir -maxdepth 1 -name \*.so.[0-9] -exec basename {} \;`
		do
			if [ "$(file -L "$_dir/$_F" | awk '/\sELF\s/{print $2}')" = "ELF" ]; then
				_fd_libpro "$_dir/$_F"
			fi
		done
	done

	pushd "${addep_tmp}" >/dev/null
	test -z "$(_do_dup provides)" || provides=($(_do_dup provides))
	popd >/dev/null
}

_add_depends() {
	local _ELF=()
	local _F _PATH
	msg2 "$(gettext "Finding "%s" files...")" "ELF"

	_fd_libdep()
	{
		local sofile
		local soarch=$(LC_ALL=C readelf -h "$1" | sed -n 's/.*Class.*ELF\(32\|64\)/\1/p'); shift
		for sofile in $@; do
			[[ -n "$soarch" ]] || continue
			[[ -n "$sofile" ]] || continue
			local sof="${sofile/\.so\.*/.so}"
			local soversion="${sofile##*\.so\.}"
			echo "${sof}=${soversion}-${soarch}" >> "${addep_tmp}/.dep"
		done
	}

	[ ! -d ./usr/lib ] || _PATH="./usr/lib"
	[ ! -d ./usr/lib32 ] || _PATH+=" ./usr/lib32"
	[ ! -d ./usr/libexec ] || _PATH+=" ./usr/libexec"
	[ ! -d ./usr/bin ] || _PATH+=" ./usr/bin"
	[ ! -d ./usr/sbin ] || _PATH+=" ./usr/sbin"
	[ ! -d ./opt ] || _PATH+=" ./opt"

	for _F in $(find ${_PATH} ! -type d -executable); do
		if file -L "${_F}" | grep -q '\sELF\s'; then
			_ELF+=("${_F}")
		fi
	done

	if [[ -n "${_ELF[@]}" ]]; then
		rm -f "${addep_tmp}/.dep"
		msg2 "$(gettext "Adding dependencies by dynamic linked library...")"

		for _F in ${_ELF[@]}; do
			_fd_libdep "$_F" `LC_ALL=C readelf -d "$_F" 2>/dev/null | sed -nr 's/.*(NEEDED).*Shared library: \[(.*)\].*/\2/p'`
		done
		if [[ -n "${depends[@]}" ]]; then
			rm -f "${addep_tmp}/.depends"
			for i in ${depends[@]}; do echo "$i" >> "${addep_tmp}/.depends"; done
		fi

		pushd "${addep_tmp}" >/dev/null
		touch .dep{,ends}
		cat .dep{,ends} > dep && rm .dep{,ends}
		while read -r p; do sed -i "/^${p}$/d" dep; done < "pro"
		for _F in ${_ELF[@]}; do sed -i "/^$(basename "$_F")=.*$/d" dep; done
		test -z "$(_do_dup depends)" || depends=(`_do_dup depends`)
		popd >/dev/null
	fi
}

tidy_addep() {
	if ! check_option "addep" "n"; then
		local addep_tmp="$(mktemp -d ${BUILDDIR}/ADDEP.XXXXXXXXX)"
		case "${pkgname}" in *-libx32) ;;
			glibc*|musl) _add_provides ;;
			*) _add_provides; [ "$ADDEP_NODEP" ] || _add_depends ;;
		esac
		rm -rf "${addep_tmp}"
	fi
}
