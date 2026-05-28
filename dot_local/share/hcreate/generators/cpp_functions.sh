gen_cpp_functions() {
	local path="$1"
	local name
	name=$(path_basename "$path")
	local guard
	guard=$(create_guard_name "$name" "hpp")

	mkdir_parent "$path"

	local hpp="$path.hpp"
	local cpp="$path.cpp"

	{
		write_guard_begin "$guard"

		if [[ -n "$NAMESPACE" ]]; then
			ns_open "$NAMESPACE"
			printf "\n"
		fi

		cat <<EOF
// ============================================================================
// Functions
// ============================================================================


EOF

		if [[ -n "$NAMESPACE" ]]; then
			ns_close "$NAMESPACE" ""
		fi

		write_guard_end "$guard"
	} >"$hpp" || true

	if [[ "$HPP_ONLY" != true ]]; then
		{
			printf "#include \"%s.hpp\"\n\n" "$name"

			if [[ -n "$NAMESPACE" ]]; then
				ns_open "$NAMESPACE"
				printf "\n"
			fi

			if [[ -n "$NAMESPACE" ]]; then
				ns_close "$NAMESPACE" ""
			fi
		} >"$cpp" || true
	fi
}

