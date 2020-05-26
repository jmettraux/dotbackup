#!/bin/sh

BD=~/.backup
HNAME=$(hostname -s)
KVER="darwin-$(uname -r)"

if [ ! -f $BD/targets.txt ]; then
  echo "$BD/targets.txt not present, nothing to backup"
  exit 1
fi

TARGETS=$(ruby -e "print File.readlines('$BD/targets.txt').map(&:strip).select { |l| l.size > 0 && l[0, 1] != '#' }.join(' ')")

cd ~ && tarsnap -c \
  --keyfile "$BD/$HNAME""_tarsnap.key" \
  --cachedir $BD/cache \
  -f "$HNAME-$KVER-$(date +%Y%m%d_%H%M%S)" \
    $TARGETS

