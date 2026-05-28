gen_cpp_class() {
	local path="$1"
	local name
	name=$(path_basename "$path")
	local guard
	guard=$(create_guard_name "$name" "hpp")

	mkdir_parent "$path"

	local hpp="$path.hpp"
	local cpp="$path.cpp"

	# ---- HPP ----
	{
		write_guard_begin "$guard"

		if [[ -n "$NAMESPACE" ]]; then
			ns_open "$NAMESPACE"
			printf "\n"
		fi

		cat <<EOF
class ${name} {

private:
	// attributes

public:

	// ========================================================================
	// Construction / Destruction
	// ========================================================================
	${name}();
	~${name}();

	// ========================================================================
	// Methods
	// ========================================================================


private:
	// ? Forbidden
	${name}(const ${name} &other);
	${name}& operator=(const ${name} &other);
};

EOF

		if [[ -n "$NAMESPACE" ]]; then
			ns_close "$NAMESPACE" ""
		fi

		write_guard_end "$guard"
	} >"$hpp" || true

	# ---- CPP ----
	if [[ "$HPP_ONLY" != true ]]; then
		{
			printf "#include \"%s.hpp\"\n\n" "$name"

			if [[ -n "$NAMESPACE" ]]; then
				ns_open "$NAMESPACE"
				printf "\n"
			fi

			cat <<EOF
// ============================================================================
// Construction / Destruction
// ============================================================================

${name}::${name}()
{}

${name}::${name}(const ${name} &other)
{
	(void)other;
}

${name}::~${name}()
{}

// ============================================================================
// Operators
// ============================================================================

${name}& ${name}::operator=(const ${name} &other)
{
	if (this != &other)
	{
		(void)other;
	}
	return *this;
}

// ============================================================================
// Methods
// ============================================================================

EOF

			if [[ -n "$NAMESPACE" ]]; then
				ns_close "$NAMESPACE" ""
			fi

		} >"$cpp" || true
	fi
}

