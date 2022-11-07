INPUT_FILES = ${wildcard tity/*.sh}
CONF_FILES  = ${wildcard pacman.d/*}

SYSCONFDIR ?= /etc
PREFIX    ?= /usr
BINDIR    ?= ${PREFIX}/bin
DATADIR ?= ${PREFIX}/share
RUNSHELL ?= ${BINDIR}/bash

INSDIR = ${DESTDIR}/${DATADIR}/makepkg/tity
CONFDIR = ${DESTDIR}/${SYSCONFDIR}/pacman.d

build:
	sed -e 's:@DATADIR@:${DATADIR}:g' -i ${INPUT_FILES}
	sed -e 's:@RUNSHELL@:${RUNSHELL}:g' -i ${INPUT_FILES}

install: build
	install -d "${INSDIR}" "${CONFDIR}"
	install -m 644 -t "${OUTDIR}" ${INPUT_FILES}
	install -m 644 -t "${CONFDIR}" ${CONF_FILES}
