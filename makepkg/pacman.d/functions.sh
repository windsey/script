is_true() {
	[ "$1" = "1" ] || [ "$1" = "y" ] || [ "$1" = "yes" ] || \
	[ "$1" = "true" ] || [ "$1" = "Y" ] || [ "$1" = "YES" ] || [ "$1" = "TRUE" ]
}

add_mkdep() {
	test $makepkg_running && return
	local dep deps skip
	for dep in $@; do
		for deps in "${makedepends[@]}"; do
			if [[ "$dep" =  "$deps" || "$dep" =  "${deps%>*}" || \
			"$dep" =  "${deps%<*}" || "$dep" =  "${deps%=*}" ]]; then
				skip=1; break
			fi
		done
		if [ "$skip" != "1" ]; then makedepends+=($dep); fi
	done
}

doinsman() {
	local page
	for page; do
		install -Dm644 "${page}" -t "${pkgdir}/usr/share/man/man${page##*.}"
	done
}

_pick() {
	local p="$1" f d; shift
	for f; do
		d="$srcdir/$p/${f#$pkgdir/}"
		mkdir -p "$(dirname "$d")"
		mv "$f" "$d"
		rmdir -p --ignore-fail-on-non-empty "$(dirname "$f")"
	done
}
