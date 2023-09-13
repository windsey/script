#!@RUNSHELL@
#
#   html.sh - Split HTML documentation files from the package
#
#   Copyright (c) 2008-2021 Pacman Development Team <pacman-dev@archlinux.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

[[ -n "$LIBMAKEPKG_TIDY_HTML_SH" ]] && return
LIBMAKEPKG_TIDY_HTML_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('html')
tidy_remove+=('tidy_html')
stag_name="HTML-staging-${pkgname}"

split_html_pkg() {
	local html_dir HTML_DIR d
	for d in ${DOC_DIRS[@]}; do
		[[ -d "$d" ]] || continue
		html_dir=($(find "$d" -type d -iname html))
		[[ -z ${html_dir[*]} ]] || HTML_DIR+=(${html_dir[@]})
	done
	if [[ -n "${HTML_DIR[@]}" ]]; then
		for d in ${HTML_DIR[@]}; do
			install -d "${PKGDEST}/${stag_name}/usr/share/doc/$pkgname"
			cp -a "$d" "${PKGDEST}/${stag_name}/usr/share/doc/$pkgname/"html
			rm -r "$d"
			local HTML_AD="$(realpath $(dirname $d))" HTML_BD="$(realpath $(dirname $d)/..)"
			find "$HTML_AD" -type d -empty -delete
			find "$HTML_BD" -type d -empty -delete
		done
		pushd "${PKGDEST}/${stag_name}" &>/dev/null
		[[ ! -f "${PKGDEST}/HTML/${pkgname}-${pkgver}-html.tgz" ]] || rm -f "${PKGDEST}/HTML/${pkgname}-${pkgver}-html.tgz"
		install -d "${PKGDEST}/HTML"
		bsdtar -zcf "${PKGDEST}/HTML/${pkgname}-${pkgver}-html.tgz" .
		popd &>/dev/null
		rm -r "${PKGDEST}/${stag_name}"
	fi

	for d in ${DOC_DIRS[@]}; do
		[[ -d "$d" ]] || continue
		find "$d" -depth -type d -exec rmdir --ignore-fail-on-non-empty '{}' \;
	done
}

tidy_html() {
	if check_option "docs" "y" && [[ -n "${DOC_DIRS[*]}" ]] && ! check_option "html" "y"; then
		msg2 "$(gettext "Removing doc files..."|sed 's/doc/html/')"
		split_html_pkg
	fi
}
