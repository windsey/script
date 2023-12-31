#!@RUNSHELL@
#
#   lfs.sh - Set up package groups, and run custom CMD
#

[[ -n "$LIBMAKEPKG_TIDY_LFS_SH" ]] && return
LIBMAKEPKG_TIDY_LFS_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('lfs')
tidy_remove+=('tidy_zzz_lfs')

_add_group() {
	local g lfs=1
	for g in split-{doc,page,staticlibs}; do
		if echo "${groups[@]}" | grep -w -q "$g"; then
			lfs=0; break
		fi
	done
	[ $lfs -eq 0 ] || groups+=(lfs)
}

tidy_cus_cmd() {
	local opt
	local tmpdir="$(mktemp -d ${BUILDDIR}/LFS.CMD.XXXXXXXXX)"
	local tmpfile="$(mktemp $tmpdir/optdep.${pkgbase}.XXXXXX)"

	# fix write_kv_pair options in .BUILDINFO
	tidy_cus_chopt() {
		if [ "$1" = "n" ]; then
			if echo ${OPTIONS[@]} | grep -Eq "^${2:1}\s|\s${2:1}\s|\s${2:1}$"
			then
				OPTIONS=(`echo ${OPTIONS[@]}|sed "s/${2:1}/${2}/"`)
			fi
		else
			if echo ${OPTIONS[@]} | grep -Eq "^!${2}\s|\s!${2}\s|\s!${2}$"
			then
				OPTIONS=(`echo ${OPTIONS[@]}|sed "s/\!${2}/${2}/"`)
			fi
		fi
	}

	if [[ -n "${options[@]}" ]]; then
		for opt in ${options[@]}; do
			case "$opt" in
				'!'*) tidy_cus_chopt n "${opt}";;
				*) tidy_cus_chopt y "${opt}"	;;
			esac
		done
	fi
	unset -f tidy_cus_chopt

	if [[ -n "${optdepends[@]}" ]]; then
		for opt in {0..20}; do
			[[ -n "${optdepends[$opt]}" ]] || break
			echo "${optdepends[$opt]}" >> $tmpfile
		done
		sort -u $tmpfile > ${tmpdir}/opt
		optdepends=()
		while read -r opt; do
			optdepends+=("$opt")
		done < ${tmpdir}/opt
	fi

	rm -rf "$tmpdir"
}

tidy_zzz_lfs() {
	if check_option "lfs" "y"; then
		case "${pkgname}" in *-lib32|*-libx32) ;;
			*) _add_group ;;
		esac
	fi

	tidy_cus_cmd
}
