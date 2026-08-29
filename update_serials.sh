#!/bin/sh
SERIAL=$(git log -1 --format="%ad" --date=format:"%y%m%d" -- $1)
echo "Updating serial of $1 to $SERIAL"
sed -i "2s/[0-9][0-9][0-9][0-9][0-9][0-9]/$SERIAL/" $1
