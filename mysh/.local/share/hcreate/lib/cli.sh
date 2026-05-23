
print_help() {
	cat <<'EOF'
Usage:
  hcreate [options] <path/to/Name> [<path/to/OtherName> ...]

  Each file musn't exist.

Modes (C++):
  (default)           Generate a concrete C++ class (.hpp + .cpp)
  --interface         Generate an interface (pure abstract class)
  --template          Generate a template class (no .cpp)
  --functions         Generate a free-functions header (no class)

Modes (C):
  --c                 Generate a C header (.h) and optionally a .c

Options:
  --namespace name    Wrap generated code in the given namespace
  --honly             Only generate header file
  --tpp               With --template: generate a .tpp file
  -o, --overwrite     Overwrite files if they already exist
  -h, --help          Display this help and exit
EOF
}

parse_cli() {
	LANG="cpp"
	TYPE="class"
	NAMESPACE=""
	HPP_ONLY=false
	WANT_TPP=false
	OVERWRITE=false
	PATHS=()

	while [[ $# -gt 0 ]]; do
		case "$1" in
			--c) LANG="c" ;;
			--interface) TYPE="interface" ;;
			--template) TYPE="template" ;;
			--functions) TYPE="functions" ;;
			--namespace) shift; NAMESPACE="$1" ;;
			--honly) HPP_ONLY=true ;;
			--tpp) WANT_TPP=true ;;
			-o|--overwrite) OVERWRITE=true ;;
			-h|--help)
				print_help
				exit 0
				;;
			-*) die "unrecognized option '$1'" ;;
			*) PATHS+=("$1") ;;
		esac
		shift
	done

	if [[ ${#PATHS[@]} -eq 0 ]]; then
		die "no target specified"
	fi
}
