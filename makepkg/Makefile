CONF_FILES  = ${wildcard pacman.d/*}
INS_FILES = ${wildcard tidy/*.sh}
ENV_FILES = ${wildcard buildenv/*.sh}

SYSCONFDIR ?= /etc
PREFIX    ?= /usr
BINDIR    ?= ${PREFIX}/bin
DATADIR ?= ${PREFIX}/share
RUNSHELL ?= ${BINDIR}/bash

CONFDIR = ${DESTDIR}/${SYSCONFDIR}/pacman.d
INSTALLDIR = ${DESTDIR}/${DATADIR}/makepkg

INSDIR = ${INSTALLDIR}/tidy
ENVDIR = ${INSTALLDIR}/buildenv

build:
	sed -e 's:@DATADIR@:${DATADIR}:g' -i ${INS_FILES} ${ENV_FILES}
	sed -e 's:@RUNSHELL@:${RUNSHELL}:g' -i ${INS_FILES} ${ENV_FILES}

install: build
	install -d "${CONFDIR}" "${INSDIR}" "${ENVDIR}"
	install -m 644 -t "${CONFDIR}" ${CONF_FILES}
	install -m 644 -t "${INSDIR}" ${INS_FILES}
	install -m 644 -t "${ENVDIR}" ${ENV_FILES}
