#!@RUNSHELL@
#
#   spdoc.sh - Split documentation files from the package
#

[[ -n "$LIBMAKEPKG_TIDY_SPDOC_SH" ]] && return
LIBMAKEPKG_TIDY_SPDOC_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('spdoc')
tidy_remove+=('tidy_spdoc')

split_doc_pkg() {
	local doc_dir SPLIT_DOC_PKG doc_link
	for doc_dir in ${DOC_DIRS[@]}; do
		[[ -d "$doc_dir" ]] || continue
		[[ -n "$(find $doc_dir ! -type d)" ]] || continue
		(("$(du -s $doc_dir | cut -f1)">512)) || continue

		local stag_base="${BUILDDIR}/split-doc-staging_${pkgname}"
		local stag_name="$stag_base/$(dirname $doc_dir)"
		install -d "${stag_name}"

		pushd "${doc_dir}" >/dev/null
		for doc_link in $(find . -maxdepth 1 -type l ! -name '.' -exec basename {} \;); do
			local link_target="$(readlink $doc_link)"
			rm $doc_link

			if [ "${link_target:0:1}" = '/' ]; then
				[ -d "${pkgdir}${link_target}" ] || continue
				mv "${pkgdir}${link_target}" ${doc_link}
				ln -sr "${pkgdir}/${doc_dir}/${doc_link}" "${pkgdir}${link_target}"
			else
				[ -d "${link_target}" ] || continue
				mv ${link_target} ${doc_link}
				ln -sr "${pkgdir}/${doc_dir}/${doc_link}" ${link_target}
			fi
		done
		popd >/dev/null

		mv "$doc_dir" "${stag_name}"
		rmdir "$(dirname $doc_dir)" --ignore-fail-on-non-empty
		( cd "$stag_base/$doc_dir"; [ -d "$pkgname" ] && ln -s "${pkgname}"{,-${pkgver}} )
		SPLIT_DOC_PKG=1
	done

	if test "${SPLIT_DOC_PKG}"; then
		msg2 "$(gettext "Splitting "%s" files into separate packages...")" "doc"
		install -Dm644 /dev/stdin "${BUILDDIR}/PKGBUILD" <<-EOF
		pkgname=${pkgname}-doc
		pkgver=${pkgver}
		pkgrel=${pkgrel}
		pkgdesc="${pkgdesc} (Split doc files)"
		arch=(any)
		url="$url"
		license=(${license[@]})
		groups=(split-doc)
		options=('!emptydirs' docs '!spdoc' xz '!addep')
		SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
		package() {
			mv "${stag_base}/"* \${pkgdir} && rmdir "${stag_base}"
		}
		EOF
		optdepends+=("${pkgname}-doc: Split doc files for $pkgname")
		(cd "${BUILDDIR}"; LD_LIBRARY_PATH= LD_PRELOAD= FAKEROOTKEY= FAKED_MODE= makepkg -c &> /dev/null &)
	fi
}

tidy_spdoc() {
	if check_option "docs" "y" && [[ -n "${DOC_DIRS[*]}" ]] && ! check_option "spdoc" "n"; then
		split_doc_pkg
	fi
}
