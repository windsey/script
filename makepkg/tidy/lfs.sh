#!@RUNSHELL@
#
#   lfs.sh - Set up package provides and groups
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

[[ -n "$LIBMAKEPKG_TIDY_LFS_SH" ]] && return
LIBMAKEPKG_TIDY_LFS_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('lfs')
tidy_remove+=('tidy_lfs')

_provides_one() {
    case "$pkgname" in
    *-lfs)
        provides=("${pkgname%-lfs}=$pkgver")
    ;;
    *-blfs)
        provides=("${pkgname%-blfs}=$pkgver")
    ;;
    *)
        provides=("${pkgname}-lfs=$pkgver")
    ;;
    esac
}

_provides_two() {
    local _provides
    for i in ${provides[@]}; do
        [[ "${i%=*}" == "$pkgname" ]] || _provides+=("$i")
    done

    case "$pkgname" in
    *-lfs)
        [[ "${_provides[@]}" =~ "${pkgname%-lfs}=$pkgver" ]] || _provides+=("${pkgname%-lfs}=$pkgver")
    ;;
    *-blfs)
        [[ "${_provides[@]}" =~ "${pkgname%-blfs}=$pkgver" ]] || _provides+=("${pkgname%-blfs}=$pkgver")
    ;;
    *)
        [[ "${_provides[@]}" =~ "${pkgname}-lfs=$pkgver" ]] || _provides+=("${pkgname}-lfs=$pkgver")
    ;;
    esac

    [[ -z "${_provides[@]}" ]] || provides=("${_provides[@]}")
}

_group_fix() {
	for i in ${groups[@]}; do
		echo "$i" >> "$srcdir/g"
	done
	awk '!a[$0]++' "$srcdir/g" > "$srcdir/groups"
	rm "$srcdir/g"
	groups=($(<"$srcdir/groups"))
}

tidy_lfs() {
	if check_option "lfs" "y"; then
        if [[ "${pkgname//*-/-}" != '-lfs' ]]
        then
            [[ "${groups[@]}" =~ 'lfs-core' ]] || groups+=(lfs)
			[[ -z "${groups[@]}" ]] || _group_fix
            [[ -z "${provides[@]}" ]] && _provides_one || _provides_two
        else
            [[ -z "${provides[@]}" ]] && _provides_one || _provides_two
        fi
	fi
}
