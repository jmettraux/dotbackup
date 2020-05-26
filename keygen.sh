#!/bin/sh

tarsnap-keygen \
	--keyfile ~/.backup/$(hostname -s)_tarsnap.key \
	--user jmettraux@gmail.com \
	--machine $(hostname -s)

