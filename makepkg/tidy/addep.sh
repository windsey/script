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
	local _f="${1::3}" _args; touch ${_f}
	for _args in {ld{,64}-{linux,musl,uClibc}*.so,lib{c,m}.so,lib*_debug.so,libsystemd-*.so}
	do
		if grep -q "^${_args/\*/.*}" ${_f}; then
			sed -i "/^${_args/\*/.*}/d" ${_f}
		fi
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
	local _dir f d ld_path=()
	if [ "$ADDEP_NOPRO" ]; then
		return 0
	fi

	fd_libpro() {
		local soarch sof sofile soversion
		for f; do
		if LC_ALL=C readelf -h "$f" 2>/dev/null | grep -q '.*Type:.*DYN (Shared object file).*'; then
			soarch=$(LC_ALL=C readelf -h "$f" 2>/dev/null | sed -n 's/.*Class.*ELF\(32\|64\)/\1/p')
			sofile=$(LC_ALL=C readelf -d "$f" 2>/dev/null | sed -n 's/.*Library soname: \[\(.*\)\].*/\1/p')
			[[ -n $soarch ]] || continue
			[[ -n $sofile ]] || continue
			sof="${sofile/\.so\.*/.so}"
			soversion="${sofile##*\.so\.}"
			echo "${sof}=${soversion}-${soarch}" >> "${addep_tmp}/pro"
		fi
		done
	}

	if [[ -n ${provides[@]} ]]; then
		for i in ${provides[@]}; do echo "$i" >> "${addep_tmp}/pro"; done
	fi
	for f in /etc/{ld.so.conf{,.d/\*.conf},ld-musl-\*.path}; do
		[[ -f $f ]] || continue
		while read -r d; do
			[[ "${d::1}" = "/" ]] || continue
			ld_path+=("${d:1}")
		done < $f
	done

	for _dir in usr/lib{,32} ${ld_path[@]}; do
		[ -d "$_dir" ] || continue
		case "$_dir" in *usr/libx32*) continue;; esac
		fd_libpro $(find $_dir -maxdepth 1 -type f -name \*.so\*)
	done

	cd "${addep_tmp}"
	test -z "$(_do_dup provides)" || provides=($(_do_dup provides))
	cd - >/dev/null
}

_add_depends() {
	local _ELF=() _PATH
	if [ "$ADDEP_NODEP" ]; then
		return 0
	fi

	fd_libdep() {
		local soarch="$1"; shift
		local sofile sof soversion
		[[ -n $soarch ]] || return
		for sofile; do
			sof="${sofile/\.so\.*/.so}"
			soversion="${sofile##*\.so\.}"
			[[ -n $soversion ]] || continue
			echo "${sof}=${soversion}-${soarch}" >> "${addep_tmp}/.dep"
		done
	}

	for i in usr/{lib{,32,exec},sbin} opt; do
		[ ! -d "./$i" ] || _PATH+=" ./$i"
	done
	_PATH+=" $(find -type d -name bin)"
	if [[ -n ${_PATH} ]]; then
		msg2 "$(gettext "Finding "%s" files...")" "ELF"
		for i in $(find ${_PATH} ! -type d -executable); do
			if [[ $(head -c4 "$i") == $'\x7fELF' ]]; then _ELF+=("$i"); fi
		done
	fi

	if [[ -n ${_ELF[@]} ]]; then
		msg2 "$(gettext "Adding dependencies by dynamic linked library...")"
		fd_libdep "$(LC_ALL=C readelf -h "${_ELF[@]}" 2>/dev/null | sed -n 's/.*Class.*ELF\(32\|64\)/\1/p' | sort -u)" \
			$(LC_ALL=C readelf -d "${_ELF[@]}" 2>/dev/null | sed -nr 's/.*(NEEDED).*Shared library: \[(.*)\].*/\2/p' | sort -u)

		if [[ -n ${depends[@]} ]]; then
			for i in ${depends[@]}; do echo "$i" >> "${addep_tmp}/.depends"; done
		fi

		cd "${addep_tmp}"
		touch .dep{,ends}; cat .dep{,ends} > dep && rm .dep{,ends}
		while read -r p; do [ "$p" ] || continue; sed -i "/^${p}$/d" dep; done < pro
		for i in ${_ELF[@]}; do sed -i "/^$(basename "$i")=.*$/d" dep 2>/dev/null; done
		test -z "$(_do_dup depends)" || depends=(`_do_dup depends`)
		cd - >/dev/null
	fi
}

tidy_addep() {
	if ! check_option "addep" "n"; then
		local addep_tmp="$(mktemp -d ${BUILDDIR}/ADDEP.XXXXXXXXXX)"
		case "${pkgname}" in *-libx32) ;;
			glibc*) _add_provides;;
			*) _add_provides; _add_depends;;
		esac
		rm -rf "${addep_tmp}"
	fi
}
