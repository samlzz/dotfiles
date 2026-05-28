
gen_cpp_interface() {
	local path="$1"
	local name
	name=$(path_basename "$path")
	local guard
	guard=$(create_guard_name "$name" "hpp")
	local eol
	eol=$(end_of_directive_line)

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
class ${name} {

public:
	virtual ~${name}()${eol}
	virtual void doSomething() = 0;
};

EOF

		if [[ -n "$NAMESPACE" ]]; then
			ns_close "$NAMESPACE"
		fi

		write_guard_end "$guard"
	} > "$hpp" || true

	if [[ "$HPP_ONLY" != true ]]; then
		{
			printf '#include "%s.hpp"\n\n' "$name"
			printf "%s::~%s() {}\n" "$name" "$name"
		} > "$cpp" || true
	fi
}
