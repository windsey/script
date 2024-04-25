#!@RUNSHELL@
#
#   net.sh - Limit the network connection of the compilation environment
#

[[ -n "$LIBMAKEPKG_BUILDENV_NET_SH" ]] && return
LIBMAKEPKG_BUILDENV_NET_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/option.sh"

build_options+=('net')
buildenv_functions+=('buildenv_net')

buildenv_net() {
	if ! check_option "net" "y"; then
		local net="localhost:255255"
		export {all,ftp,http,https}_proxy=$net RSYNC_PROXY=$net
	fi
}
