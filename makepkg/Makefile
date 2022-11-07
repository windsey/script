INPUT_FILES = ${wildcard tity/*.sh}
CONF_FILES  = ${wildcard pacman.d/*}

SYSCONFDIR ?= /etc
PREFIX    ?= /usr
BINDIR    ?= ${PREFIX}/bin
DATADIR ?= ${PREFIX}/share
SHELL ?= ${BINDIR}/bash

OUTDIR = ${DESTDIR}/${DATADIR}/makepkg/tity
CONFDIR = ${DESTDIR}/${SYSCONFDIR}/pacman.d

all: ${INPUT_FILES}

%:
	sed -e 's:@SHELL@:${SHELL}:g' $< > $@
	sed -e 's:@DATADIR@:${DATADIR}:g' $< > $@

install:
	install -d "${OUTDIR}" "${CONFDIR}"
	install -m 644 -t "${OUTDIR}" ${INPUT_FILES}
	install -m 644 -t "${CONFDIR}" ${CONF_FILES}
