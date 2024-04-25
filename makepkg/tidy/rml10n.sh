#!@RUNSHELL@
#
#   rml10n.sh - Remove locale files except specified
#

[[ -n "$LIBMAKEPKG_TIDY_LOCALE_SH" ]] && return
LIBMAKEPKG_TIDY_lOCALE_SH=1

LIBRARY=${LIBRARY:-'@DATADIR@/makepkg'}

source "$LIBRARY/util/message.sh"
source "$LIBRARY/util/option.sh"

packaging_options+=('rml10n')
tidy_remove+=('tidy_rml10n')

tidy_rml10n() {
	if [[ -n ${keep_locales[*]} ]] && ! check_option "rml10n" "n"; then
		[ -d usr/share/locale ] || return 0
		msg2 "$(gettext "Removing unwanted message translation files...")"
		local locale temp="$(mktemp -d)"
		local locale_dir="usr/share/locale"
		for locale in ${keep_locales[*]}; do
			[[ $(find ${locale_dir} -maxdepth 1 -type d -name "$locale"\*) ]] || continue
			find ${locale_dir} -maxdepth 1 -type d -name "$locale"\* | xargs mv -t "${temp}" --
		done
		find ${locale_dir} -maxdepth 1 \! -type d -exec mv -t "${temp}" -- {} \;
		rm -rf ${locale_dir}/*
		[[ -z $(ls "${temp}") ]] || mv "${temp}/"* ${locale_dir}
		rmdir "${temp}" ${locale_dir} --ignore-fail-on-non-empty
	fi
}
