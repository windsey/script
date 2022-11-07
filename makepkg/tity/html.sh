#!@RUNSHELL@
#
#   docs.sh - Remove documentation files from the package
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

_html() {
    local html_dir HTML_DIR
    for d in ${DOC_DIRS[@]}; do
        if [[ -d "$d" ]]; then
            html_dir=($(find "$d" -type d -iname html))
            [[ -z ${html_dir[*]} ]] || HTML_DIR+=(${html_dir[@]})
        fi
    done
    if [[ -n "${HTML_DIR[@]}" ]]; then
        for d in ${HTML_DIR[@]}; do
            install -d "${PKGDEST}/HTML/usr/share/doc/$pkgname"
            cp -a "$d" "${PKGDEST}/HTML/usr/share/doc/$pkgname/"html
            rm -r "$d"
        done
        pushd "${PKGDEST}/HTML" &>/dev/null
        [[ ! -f "${PKGDEST}/HTML/${pkgname}-${pkgver}-html.tgz" ]] || rm -f "${PKGDEST}/HTML/${pkgname}-${pkgver}-html.tgz"
        bsdtar -zcf "${PKGDEST}/HTML/${pkgname}-${pkgver}-html.tgz" *
        popd &>/dev/null
        rm -r "${PKGDEST}/HTML/usr"
    fi
	
    for d in ${DOC_DIRS[@]}; do
        [[ ! -d "$d" ]] || find "$d" -depth -type d -exec rmdir '{}' \; 2>/dev/null
    done
}

tidy_html() {
	if check_option "html" "n" && [[ -n ${DOC_DIRS[*]} ]] && check_option "docs" "y"; then
		msg2 "$(gettext "Removing doc files..."|sed 's/doc/html/')"
		_html
	fi
}
