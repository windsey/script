#!@RUNSHELL@
#
#   bldpkg.sh - Yes/NO write packages installed at build time to .BUILDINFO
#

[[ -n "$LIBMAKEPKG_TIDY_BLDPKG_SH" ]] && return
LIBMAKEPKG_TIDY_BLDPKG_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/option.sh"

packaging_options+=('bldpkg')
tidy_remove+=('tidy_bldpkg')

tidy_bldpkg() {
	if check_option "bldpkg" "n"; then
		W_BUILDINFO_PKG="N"
	fi
}
