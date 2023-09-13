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
	touch ${_f}
	for i in {ld-linux*so,ld-musl*so,libc.so,libm.so,libresolv.so,lib*_debug.so}
	do
		sed -i "/^${i/\*/.*}/d" ${_f}
	done

	case "${_f}" in
		pro) sed -i '/\.so\.[0-9].*$/d' ${_f} ;;
		dep) sed -i 's/\.so\.[0-9].*/.so/' ${_f} ;;
	esac
	sort -u ${_f} > $1
	echo "$(<$1)"
}

_add_provides() {
	local _F
	rm -f "${srcdir}/pro"

	if [[ -n "${provides[@]}" ]]; then
		for i in ${provides[@]}; do echo "$i" >> "${srcdir}/pro"; done
	fi

	if [ -d usr/lib ]; then
		for _F in `find usr/lib -maxdepth 1 -name \*.so -exec basename {} \;` \
			`find usr/lib -maxdepth 1 -name \*.so.[0-9] -exec basename {} \;`
		do
			if [ "$(file -L usr/lib/$_F | awk '/\sELF\s/{print $2}')" = "ELF" ]; then
				echo "$_F" >> "${srcdir}/pro"
			fi
		done
	fi

	pushd "${srcdir}" >/dev/null
	test -z "$(_do_dup provides)" || provides=($(_do_dup provides))
	popd >/dev/null
}

_add_depends() {
	local _ELF=()
	local _F _PATH
	msg2 "$(gettext "Finding "%s" files...")" "ELF"

	[ ! -d ./usr/lib ] || _PATH="./usr/lib"
	[ ! -d ./usr/lib32 ] || _PATH+=" ./usr/lib32"
	[ ! -d ./usr/libexec ] || _PATH+=" ./usr/libexec"
	[ ! -d ./usr/bin ] || _PATH+=" ./usr/bin"
	[ ! -d ./usr/sbin ] || _PATH+=" ./usr/sbin"
	[ ! -d ./opt ] || _PATH+=" ./opt"
	for _F in $(find ${_PATH} ! -type d ! -name '*.a' ! -name '*.o' ! -name '*.gz' ! -name '*.mo' ! -name '*.py' \
		! -name '*.h' ! -name '*.hpp' ! -name '*.cmake' ! -name '*.c' ! -name '*.conf' ! -name '*.xml' ! -name '*.html' \
		! -name '*.pl' ! -name '*.pm' ! -name '*.rb' ! -name '*.rbs' ! -name '*.tcc' ! -name '*.def' ! -name '*.txt' \
		! -name '*.svg' ! -name '*.png' ! -name '*.sh' ! -name '*.yaml' ! -name '*.in' ! -name 'Kconfig'); do
		if [ "$(file -L ${_F} | awk '/\sELF\s/{print $2}')" = "ELF" ]; then
			_ELF+=("${_F}")
		fi
	done

	if [[ -n "${_ELF[@]}" ]]; then
		rm -f "${srcdir}/.dep"
		msg2 "$(gettext "Adding dependencies by dynamic linked library...")"

		for _F in ${_ELF[@]}; do
			LC_ALL=C readelf -d "$_F" | grep '\s(NEEDED)\s' | sed 's/^.*\[\|\]$//g' >> "${srcdir}/.dep"
		done
		if [[ -n "${depends[@]}" ]]; then
			rm -f "${srcdir}/.depends"
			for i in ${depends[@]}; do echo "$i" >> "${srcdir}/.depends"; done
		fi

		pushd "${srcdir}" >/dev/null
		touch .dep{,ends}
		cat .dep{,ends} > dep && rm .dep{,ends}
		while read -r p; do sed -i "/^$p/d" dep; done < "pro"
		for _F in ${_ELF[@]}; do sed -i "/^$(basename $_F)$/d" dep; done
		test -z "$(_do_dup depends)" || depends=(`_do_dup depends`)
		popd >/dev/null
	fi
}

tidy_addep() {
	if ! check_option "addep" "n"; then
		case "${pkgname}" in *-libx32) ;;
			glibc*|musl) _add_provides ;;
			*) _add_provides; [ "$ADDEP_NODEP" ] || _add_depends ;;
		esac
		rm -f "${srcdir}/"{dep,depends,pro,provides}
	fi
}
