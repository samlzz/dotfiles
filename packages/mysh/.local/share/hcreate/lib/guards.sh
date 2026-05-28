
create_guard_name() {
	printf "%s_%s\n" "$1" "$2" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9_]/_/g'
}

write_guard_begin() {
	printf "#ifndef __%s__\n# define __%s__\n\n" "$1" "$1"
}

write_guard_end() {
	printf "\n#endif /* __%s__ */\n" "$1"
}
