#!/usr/bin/env bash

EXT_FILES="$1"

if [ ! -f "$EXT_FILES" ]; then
	printf "You must provide a dependencies files for extensions\n" >&2
	exit 1
fi

echo "You may delete 'extensions.json' file to avoid some conflicts"
xargs -n1 code --force --install-extension < "$EXT_FILES"

