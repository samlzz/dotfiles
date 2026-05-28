gen_c_header() {
	local path="$1"
	local name
	name=$(path_basename "$path")
	local guard
	guard=$(create_guard_name "$name" "h")

	mkdir_parent "$path"

	local h="$path.h"
	local c="$path.c"

	{
		printf "#ifndef %s\n# define %s\n\n#endif\n" "$guard" "$guard"
	} >"$h" || true

	if [[ "$HPP_ONLY" != true ]]; then
		printf "#include \"%s.h\"\n" "$name" >"$c"
	fi
}

