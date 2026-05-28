
ns_open() {
	IFS="::" read -ra parts <<< "$1"
	for p in "${parts[@]}"; do
		if [[ -n "$p" ]]; then
			printf "namespace %s {\n" "$p"
		fi
	done
}

ns_close() {
	IFS="::" read -ra parts <<< "$1"
	for ((i=${#parts[@]}-1; i>=0; i--)); do
		if [[ -n "${parts[$i]}" ]]; then
			printf "} // namespace %s\n" "${parts[$i]}"
		fi
	done
}
