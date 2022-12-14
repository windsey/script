#!@RUNSHELL@
#
#   rman.sh - Deletes the specified manual page directory
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

[[ -n "$LIBMAKEPKG_TIDY_RMAN_SH" ]] && return
LIBMAKEPKG_TIDY_RMAN_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('rman')
tidy_remove+=('tidy_rman')

tidy_rman() {
	if check_option "rman" "y" && [[ -n ${RM_MAN[*]} ]]; then
		msg2 "$(gettext "Removing doc files..."|sed 's/doc/specified/')"
		rm -rf -- ${RM_MAN[@]}
	fi
}
