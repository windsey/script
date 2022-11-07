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

[[ -n "$LIBMAKEPKG_TIDY_XZ_SH" ]] && return
LIBMAKEPKG_TIDY_XZ_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('xz')
tidy_remove+=('tidy_xz')

tidy_xz() {
	if check_option "xz" "y"; then
		msg2 "$(gettext "Compress the package using xz...")"
		PKGEXT='.pkg.tar.xz'
	fi
}
