#!@RUNSHELL@
#
#   locale.sh - Remove locale files except zh from the package
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
		install -d "${PKGDEST}/L10N-staging-$pkgname/$(dirname $1)"
		cp -a "$1" "${PKGDEST}/L10N-staging-$pkgname/$(dirname $1)" && rm -rf -- "$1"
		find usr/share/locale -type d -empty -delete
	fi
}

_package_l10n() {
	if [[ -d "${PKGDEST}/L10N-staging-$pkgname" ]]; then
		pushd "${PKGDEST}/L10N-staging-$pkgname" >/dev/null 2>&1
			[[ ! -f "${PKGDEST}/L10N/$pkgname-$pkgver-l10n.tgz" ]] || rm -f "${PKGDEST}/L10N/$pkgname-$pkgver-l10n.tgz"
			install -d "${PKGDEST}/L10N"
			bsdtar -zcf "${PKGDEST}/L10N/$pkgname-$pkgver-l10n.tgz" .
		popd >/dev/null 2>&1
		rm -r "${PKGDEST}/L10N-staging-$pkgname"
	fi
}

tidy_locale() {
	if [[ -n "${LOCALE_DIRS[*]}" ]] && ! check_option "locale" "y"; then
		msg2 "$(gettext "Removing the message translation file for the specified language...")"
		for d in ${LOCALE_DIRS[@]}; do _remove_locale "$d"; done
		_package_l10n
	fi
}
