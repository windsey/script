#!@RUNSHELL@
#
#   lfs.sh - Set up package groups
#

[[ -n "$LIBMAKEPKG_TIDY_LFS_SH" ]] && return
LIBMAKEPKG_TIDY_LFS_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('lfs')
tidy_remove+=('tidy_lfs')

_add_group() {
	[[ "${groups[@]}" =~ 'lfs-core' ]] || [[ "${groups[@]}" =~ 'split-doc' ]] || groups+=(lfs)
	if [[ -n "${groups[@]}" ]]; then
		for i in ${groups[@]}; do
			echo "$i" >> "$srcdir/g"
		done
		awk '!a[$0]++' "$srcdir/g" > "$srcdir/groups"
		groups=($(<"$srcdir/groups"))
		rm -f "$srcdir/groups" "$srcdir/g"
	fi
}

tidy_lfs() {
	if check_option "lfs" "y"; then
		case "${pkgname}" in *-lib32|*-libx32) ;;
			*) _add_group ;;
		esac
	fi
}
