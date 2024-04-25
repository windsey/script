#!@RUNSHELL@
#
#   lzma.sh - Compress the package using xz or lzip
#

[[ -n "$LIBMAKEPKG_BUILDENV_LZMA_SH" ]] && return
LIBMAKEPKG_BUILDENV_LZMA_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/option.sh"

build_options+=('xz' 'lz')
buildenv_functions+=('buildenv_lzma')

buildenv_lzma() {
	if check_option "lz" "y"; then
		if type -p lzip >/dev/null; then
			PKGEXT="${PKGEXT/.tar*/.tar.lz}"
			SRCEXT="${SRCEXT/.tar*/.tar.lz}"
		else
			PKGEXT="${PKGEXT/.tar*/.tar.xz}"
			SRCEXT="${SRCEXT/.tar*/.tar.xz}"
		fi
    elif check_option "xz" "y"; then
		PKGEXT="${PKGEXT/.tar*/.tar.xz}"
		SRCEXT="${SRCEXT/.tar*/.tar.xz}"
	fi
}
