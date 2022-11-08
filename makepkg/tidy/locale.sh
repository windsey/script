#!@RUNSHELL@
#
#   locale.sh - Remove locale files except 'en/zh' from the package
#

[[ -n "$LIBMAKEPKG_TIDY_LOCALE_SH" ]] && return
LIBMAKEPKG_TIDY_lOCALE_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('locale')
tidy_remove+=('tidy_locale')

_remove_locale() {
    if [[ -d "$1" ]]; then
        install -d "${PKGDEST}/L10N/$pkgname/$(dirname $1)"
        cp -a "$1" "${PKGDEST}/L10N/$pkgname/$(dirname $1)" && rm -rf -- "$1"
    fi
}

_package_l10n() {
    if [[ -d "${PKGDEST}/L10N/$pkgname" ]]; then
        pushd "${PKGDEST}/L10N/$pkgname" &>/dev/null
            [[ ! -f "${PKGDEST}/L10N/$pkgname-$pkgver-l10n.tgz" ]] || rm -f "${PKGDEST}/L10N/$pkgname-$pkgver-l10n.tgz"
            bsdtar -zcf "${PKGDEST}/L10N/$pkgname-$pkgver-l10n.tgz" *
        popd &>/dev/null
        rm -r "${PKGDEST}/L10N/$pkgname"
    fi
}

tidy_locale() {
	if check_option "locale" "n" && [[ -n ${LOCALE_DIRS[*]} ]]; then
		msg2 "$(gettext "Removing doc files..."|sed 's/doc/locale/')"
        for d in ${LOCALE_DIRS[@]}; do _remove_locale "$d"; done
        _package_l10n
	fi
}
