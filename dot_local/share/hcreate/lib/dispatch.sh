
dispatch_cpp() {
	case "$TYPE" in
		class) gen_cpp_class "$1" ;;
		interface) gen_cpp_interface "$1" ;;
		template) gen_cpp_template "$1" ;;
		functions) gen_cpp_functions "$1" ;;
	esac
}

check_one_file()
{
	if [[ -f "$1" ]]; then
		die "cannot create '$1', file already exist"
	fi
}

check_files() {
	local ext
	if [[ "$LANG" == "c" ]]; then
		ext="h"
	else
		ext="hpp"
	fi

	for p in "${PATHS[@]}"; do

		check_one_file "${p}.${ext}"
		if [[ "$HPP_ONLY" == false ]]; then
			check_one_file "${p}.${LANG}"
		fi
		if [[ "$WANT_TPP" == true ]]; then
			check_one_file "${p}.tpp"
		fi
	done
}

main() {
	parse_cli "$@"

	if [[ "$OVERWRITE" == false ]]; then
		check_files
	fi

	if [[ "$LANG" == "c" ]]; then
		for p in "${PATHS[@]}"; do
			gen_c_header "$p"
		done
		exit 0
	fi

	for p in "${PATHS[@]}"; do
		dispatch_cpp "$p"
	done
}
