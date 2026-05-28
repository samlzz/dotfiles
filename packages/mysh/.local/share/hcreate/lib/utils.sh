
die() {
	printf "hcreate: %s\nTry 'hcreate --help' for more information.\n" "$*" >&2
	exit 1
}

mkdir_parent() {
	mkdir -p "$(dirname "$1")"
}

path_basename() {
	basename "$1"
}

end_of_directive_line() {
	if [[ "$HPP_ONLY" == true ]]; then
		printf " {}"
	else
		printf ";"
	fi
}