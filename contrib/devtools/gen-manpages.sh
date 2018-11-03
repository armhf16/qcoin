#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

QCOIND=${QCOIND:-$SRCDIR/qcoind}
QCOINCLI=${QCOINCLI:-$SRCDIR/qcoin-cli}
QCOINTX=${QCOINTX:-$SRCDIR/qcoin-tx}
QCOINQT=${QCOINQT:-$SRCDIR/qt/qcoin-qt}

[ ! -x $QCOIND ] && echo "$QCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
QCNVER=($($QCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a barter file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > barter.h2m
$QCOIND --version | sed -n '1!p' >> barter.h2m

for cmd in $QCOIND $QCOINCLI $QCOINTX $QCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${QCNVER[0]} --include=barter.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${QCNVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f barter.h2m
