#!@RUNSHELL@
#
#   addep.sh - Add dependencies through shared libraries
#
#   Copyright (c)

[[ -n "$LIBMAKEPKG_TIDY_ADDEP_SH" ]] && return
LIBMAKEPKG_TIDY_ADDEP_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('addep')
tidy_remove+=('tidy_addep')

_find_dep_pkg() {
    local LD_LIB local_pkg _depends
    for so in ${_lib_so[@]}; do
        echo "$so" >> "$srcdir/so.addep"
    done
    LD_LIB="$(awk '!a[$0]++' "$srcdir/so.addep")"
    for so in ${LD_LIB[@]}; do
        if [[ ! -e "${so#/}" ]] && [[ ! "$so" =~ 'fakeroot.so' ]] && \
        [[ "$so" != 'linux-vdso.so.1' && "${so##*/}" != 'ld-linux-x86-64.so.2' ]] && \
        [[ "${so##*/}" != 'libc.so.6' ]]
        then
            local_pkg=$(pacman -Q --quiet --owns "$so" 2>/dev/null || return 0)
            [[ -z "${local_pkg}" ]] || _depends+=("${local_pkg}")
        fi
    done
    rm "$srcdir/so.addep"

    # Do not add duplicate items
    if [[ -n "${_depends[@]}" ]]; then
        for pkg in ${_depends[@]}; do
            [[ "${depends[@]}" =~ "$pkg" ]] || depends+=("$pkg")
        done
    fi
}

_add_depends() {
    local _lib_so _so
    local _libraries=("$(find . -type f -name '*.so*')")
    local _binaries=("$(find . -type f -not -name '*.so*')")

    if [[ -n "${_libraries}" ]]; then
        for lib in ${_libraries[@]}; do
            _so=$(ldd "$lib" 2>/dev/null | awk '{print $3}')
            [[ -z "${_so}" ]] || _lib_so+=("${_so}")
        done
    fi
    if [[ -n "${_binaries}" ]]; then
        for bin in ${_binaries[@]}; do
            if [[ -x "$bin" ]]; then
                _so=$(ldd "$bin" 2>/dev/null | awk '{print $3}')
                [[ -z "${_so}" ]] || _lib_so+=("${_so}")
            fi
        done
    fi
    [[ -z "${_lib_so[@]}" ]] || _find_dep_pkg

    # seting dependency sequence to 'a-z'
    if [[ -n "${depends[@]}" ]]; then
        for dep in ${depends[@]}; do echo "$dep" >>"$srcdir/dep"; done
        sort "$srcdir/dep" > "$srcdir/depends" && rm -f "$srcdir/dep"
        sed -i "/^${pkgname}$/d" "$srcdir/depends"
        depends=("$(<"$srcdir/depends")")
    fi
}

tidy_addep() {
	if check_option "addep" "y"; then
		msg2 "$(gettext "Adding dependencies by dynamic linked library...")"
		_add_depends
	fi
}
