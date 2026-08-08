#!/bin/sh
SERIAL=$(git log -1 --format="%ad" --date=format:"%y%m%d" -- $1)
sed -i "2s/[0-9][0-9][0-9][0-9][0-9][0-9]/$SERIAL/" $1
