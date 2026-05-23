get_template_eol() {
	local hpp_flag="$HPP_ONLY"

	if [[ "$WANT_TPP" == true ]]; then
		HPP_ONLY=false
	else
		HPP_ONLY=true
	fi
	local eol
	eol=$(end_of_directive_line)

	HPP_ONLY="$hpp_flag"
	printf '%s' "$eol"
}

gen_cpp_template() {
	local path="$1"
	local name
	name=$(path_basename "$path")
	local guard
	guard=$(create_guard_name "$name" "hpp")
	local eol
	eol=$(get_template_eol)

	mkdir_parent "$path"

	local hpp="$path.hpp"
	local tpp="$path.tpp"

	{
		write_guard_begin "$guard"
		printf "# include <cstddef>\n\n"

		if [[ -n "$NAMESPACE" ]]; then
			ns_open "$NAMESPACE"
			printf "\n"
		fi

		cat <<EOF
template <typename T>
class ${name} {

public:
	// ========================================================================
	// Construction / Destruction
	// ========================================================================
	${name}()${eol}
	${name}(const ${name} &other)${eol}
	~${name}()${eol}

	// ========================================================================
	// Operators
	// ========================================================================
	${name}& operator=(const ${name} &other)${eol}
	T& operator[](size_t idx)${eol}
};

EOF

		if [[ -n "$NAMESPACE" ]]; then
			ns_close "$NAMESPACE" ""
			printf "\n"
		fi

		if [[ "$WANT_TPP" == true ]]; then
			printf "# include \"%s.tpp\"\n" "$name"
		fi

		write_guard_end "$guard"
	} >"$hpp" || true

	if [[ "$WANT_TPP" == true ]]; then
		{
			if [[ -n "$NAMESPACE" ]]; then
				ns_open "$NAMESPACE"
				printf "\n"
			fi

			cat <<EOF
// ========================================================================
// Construction / Destruction
// ========================================================================

template <typename T>
${name}<T>::${name}()
{}

template <typename T>
${name}<T>::${name}(const ${name} &other)
{
	(void)other;
}

template <typename T>
${name}<T>::~${name}()
{}

// ========================================================================
// Operators
// ========================================================================

template <typename T>
${name}<T>& ${name}<T>::operator=(const ${name} &other)
{
	if (this != &other)
	{
		(void)other;
	}
	return *this;
}

template <typename T>
T& ${name}<T>::operator[](size_t idx)
{
	(void)idx;
	static T dummy = T();
	return dummy;
}

EOF

			if [[ -n "$NAMESPACE" ]]; then
				ns_close "$NAMESPACE" ""
			fi
		} >"$tpp" || true
	fi
}

