#!@RUNSHELL@
#
#   spstaticlibs.sh - Split static library files into separate packages
#

[[ -n "$LIBMAKEPKG_TIDY_SPSTATICLIBS_SH" ]] && return
LIBMAKEPKG_TIDY_SPSTATICLIBS_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('spstaticlibs')
tidy_remove+=('tidy_spstaticlibs')

split_staticlibs_pkg() {
	local l
	local lib_split_pkg
	while IFS= read -rd '' l; do
		if [[ -f "${l%.a}.so" || -h "${l%.a}.so" ]]; then
			_pick split_static_libs "$l"; lib_split_pkg=1
		fi
	done < <(find . ! -type d -name "*.a" -print0)

	[[ -n "${lib_split_pkg}" ]] || return
	msg2 "$(gettext "Splitting static library files into separate packages...")"

	local stag_name="$(mktemp -d)"
	mv "${srcdir}/split_static_libs/"* "${stag_name}"
	rmdir "${srcdir}/split_static_libs/"

	install -Dm644 /dev/stdin "${BUILDDIR}/.PKG" <<-EOF
	pkgname=${pkgname}-static
	pkgver=${pkgver}
	pkgrel=${pkgrel}
	pkgdesc="${pkgdesc} (static libraries)"
	arch=(${arch[@]})
	url="$url"
	license=(${license[@]})
	groups=(split-staticlibs)
	options=(${options[@]} !emptydirs !docs !spstaticlibs xz !addep !bldpkg)
	SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
	package() {
		mv "${stag_name}/"* \${pkgdir} && rmdir "${stag_name}"
	}
	EOF
	(cd "${BUILDDIR}"; LD_PRELOAD= FAKEROOTKEY= makepkg -cp .PKG >/dev/null && rm .PKG)
}

tidy_spstaticlibs() {
	if check_option "staticlibs" "y"; then
		if check_option "lfs" "y"; then
			! check_option "spstaticlibs" "y" || split_staticlibs_pkg
		else
			check_option "spstaticlibs" "n" || split_staticlibs_pkg
		fi
	fi
}
