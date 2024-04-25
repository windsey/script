CONF_FILES  = $$(find makepkg.conf.d -maxdepth 1 -type f)
INS_FILES = ${wildcard tidy/*.sh}
ENV_FILES = ${wildcard buildenv/*.sh}

SYSCONFDIR ?= /etc
PREFIX    ?= /usr
BINDIR    ?= ${PREFIX}/bin
DATADIR ?= ${PREFIX}/share
RUNSHELL ?= ${BINDIR}/bash

CONFDIR = ${DESTDIR}/${SYSCONFDIR}/makepkg.conf.d
INSTALLDIR = ${DESTDIR}/${DATADIR}/makepkg

INSDIR = ${INSTALLDIR}/tidy
ENVDIR = ${INSTALLDIR}/buildenv

build:
	sed -e 's:@DATADIR@:${DATADIR}:g' -i.ori ${INS_FILES} ${ENV_FILES}
	sed -e 's:@RUNSHELL@:${RUNSHELL}:g' -i.ori ${INS_FILES} ${ENV_FILES}

install: build
	install -d "${CONFDIR}" "${INSDIR}" "${ENVDIR}"
	install -m 644 -t "${CONFDIR}" ${CONF_FILES}
	install -m 644 -t "${INSDIR}" ${INS_FILES}
	install -m 644 -t "${ENVDIR}" ${ENV_FILES}
