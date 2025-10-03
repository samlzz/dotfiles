source "$XDG_STATE_HOME/ctools/aliases.zsh"

#? for get the prototype of a function in man
manproto() {
	if [ -z "$1" ]; then
		echo "Error: No function name provided."
		exit 1
	fi
	local result section
	result=$(man "$1" | grep "$1(" -A 1 | head -5)
	section=$(echo "$result" | grep -oP "$1\(\K[0-9]+")
	if [[ $section =~ ^[0-9]+$ ]]; then
		man "$section" "$1" | grep "$1(" -A 1 | head -5
	else
		echo "$result"
	fi
}

wlf-copy() {
	if ! command -v wl-copy >/dev/null; then
		echo "Error: wl-copy command not found."
		return 1
	fi
	cat $@ | wl-copy
}

wlf-paste() {
	if ! command -v wl-paste >/dev/null; then
		echo "Error: wl-paste command not found."
		return 1
	fi
	wl-paste | cat >$1
}

cpbak() {
	cp "$1" "$1.bak"
}
