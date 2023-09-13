#!@RUNSHELL@
#
#   Set the SOURCE_DATE_EPOCH variable for reproducible builds
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

[[ -n "$LIBMAKEPKG_BUILDENV_EPOCH_SH" ]] && return
LIBMAKEPKG_BUILDENV_EPOCH_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/option.sh"

build_options+=('epoch')
buildenv_functions+=('buildenv_epoch')

buildenv_epoch() {
	if check_option "epoch" "y" && [[ -e "/etc/pacman.d/epoch" ]]; then
		. "/etc/pacman.d/epoch"
	elif check_option "epoch" "y"; then
		SOURCE_DATE_EPOCH=0
	fi
}
