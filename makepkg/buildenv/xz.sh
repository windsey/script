#!@RUNSHELL@
#
#   xz.sh - Compress the package using xz
#

[[ -n "$LIBMAKEPKG_TIDY_XZ_SH" ]] && return
LIBMAKEPKG_TIDY_XZ_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/option.sh"

build_options+=('xz')
buildenv_functions+=('buildenv_xz')

buildenv_xz() {
	if check_option "xz" "y"; then
		PKGEXT='.pkg.tar.xz'
		SRCEXT='.src.tar.xz'
	fi
}
