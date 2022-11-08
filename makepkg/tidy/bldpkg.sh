#!@RUNSHELL@
#
#   bldpkg.sh - Yes/NO write packages installed at build time to .BUILDINFO
#
#   Copyright (c) 2021 Pacman Development Team <pacman-dev@archlinux.org>
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

[[ -n "$LIBMAKEPKG_TIDY_BLDPKG_SH" ]] && return
LIBMAKEPKG_TIDY_BLDPKG_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/option.sh"

packaging_options+=('bldpkg')
tidy_remove+=('tidy_bldpkg')

tidy_bldpkg() {
	if check_option "bldpkg" "n"; then
		W_BUILDINFO_PKG="N"
	fi
}
