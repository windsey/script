#!@RUNSHELL@
#

[[ -n "$LIBMAKEPKG_BUILDENV_PKGSUFFIX_SH" ]] && return
LIBMAKEPKG_BUILDENV_PKGSUFFIX_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/option.sh"

build_options+=('psufx')
buildenv_functions+=('buildenv_pkgsuffix')

buildenv_pkgsuffix() {
	if [[ ${CHOST} != *-gnu* ]] && ! check_option "psufx" "n"; then
		case "${CHOST}" in
			*-musl*)
				PKGEXT="-musl${PKGEXT}"
				SRCEXT="-musl${SRCEXT}"
				;;
			*-uclibc*)
				PKGEXT="-uclibc${PKGEXT}"
				SRCEXT="-uclibc${SRCEXT}"
				;;
		esac
	fi
}
