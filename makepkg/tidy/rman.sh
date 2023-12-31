#!@RUNSHELL@
#
#   rman.sh - Deletes the specified manual page directory
#

[[ -n "$LIBMAKEPKG_TIDY_RMAN_SH" ]] && return
LIBMAKEPKG_TIDY_RMAN_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('rman')
tidy_remove+=('tidy_rman')

tidy_rman() {
	if [[ -n "${RM_MAN[*]}" ]] && ! check_option "rman" "n"; then
		msg2 "$(gettext "Removing unwanted man pages...")"
		rm -rf -- ${RM_MAN[@]}
	fi
}
