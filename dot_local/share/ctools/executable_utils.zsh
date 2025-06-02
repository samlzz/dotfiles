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

srcs_fill() {
	local search_dir="${1:-.}"

	if [ ! -f "Makefile" ]; then
		echo "Error: Makefile not found in current directory."
		return 1
	fi

	local file_list
	file_list=$(find "$search_dir" -type f \( -name "*.c" -o -name "*.cpp" \) |
		sed 's|.*/||' |
		sort |
		tr '\n' ' ')

	if [ -z "$file_list" ]; then
		echo "No files found in '$search_dir'"
		return 0
	fi

	sed -i -E "/### UFILES_START ###/,/### END ###/c\\
### UFILES_START ###\nFILES     ?= $file_list\n### END ###
" "Makefile"

	echo "'FILES' updated with :"
	echo "$file_list"
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
