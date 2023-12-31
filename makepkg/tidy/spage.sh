#!@RUNSHELL@
#
#   spage.sh - Split manpage and info files into separate packages
#

[[ -n "$LIBMAKEPKG_TIDY_SPAGE_SH" ]] && return
LIBMAKEPKG_TIDY_SPAGE_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('spage')
tidy_remove+=('tidy_spage')

split_page_pkg() {
	local page_dir
	local page_dirs=()
	local page_file_num=0
	local page_run_continue
	local page_split_pkg

	for page_dir in ${MAN_DIRS[@]}; do
		[[ -d "$page_dir" ]] || continue
		[[ -n "$(find $page_dir ! -type d)" ]] || continue
		page_dirs+=("$page_dir"); page_run_continue=1
	done

	[[ -n "$page_run_continue" ]] || return
	[[ -z "$(find ${page_dirs[@]} -type f | wc -l)" ]] || \
		page_file_num="$(find ${page_dirs[@]} -type f | wc -l)"
	[[ "$page_file_num" -ge 10 ]] || return

	for page_dir in ${page_dirs[@]}; do
		_pick split_page "$page_dir"
	done

	local stag_name="$(mktemp -d)"
	! mv "${srcdir}/split_page/"* "${stag_name}" || page_split_pkg=1
	rmdir "${srcdir}/split_page/"

	if test "${page_split_pkg}"; then
		msg2 "$(gettext "Splitting "%s" files into separate packages...")" "info/man"
		install -Dm644 /dev/stdin "${BUILDDIR}/PMAN" <<-EOF
		pkgname=${pkgname}-man
		pkgver=${pkgver}
		pkgrel=${pkgrel}
		pkgdesc="${pkgdesc} (Split info or man files)"
		arch=(any)
		url="$url"
		license=(${license[@]})
		groups=(split-page)
		options=(!emptydirs !docs !spage xz !addep !bldpkg)
		SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
		package() {
			mv "${stag_name}/"* \${pkgdir} && rmdir "${stag_name}"
		}
		EOF
		[ "${pkgname}" != "openssl" ] || echo 'options+=(!zipman)' >> "${BUILDDIR}/PMAN"
		optdepends+=("${pkgname}-man: Split info/man files for $pkgname")
		(cd "${BUILDDIR}"; LD_LIBRARY_PATH= LD_PRELOAD= FAKEROOTKEY= FAKED_MODE= makepkg -cp PMAN &> /dev/null)
	fi
}

tidy_spage() {
	if [[ -n "${MAN_DIRS[*]}" ]] && ! check_option "spage" "n"; then
		split_page_pkg
	fi
}
