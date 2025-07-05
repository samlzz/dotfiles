#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

get_chezmoi_source_path() {
	local path
	if ! path=$(chezmoi source-path 2>/dev/null); then
		path="$HOME/.local/share/chezmoi"
	fi
	if [[ ! -d "$path" ]]; then
		printf "Error: chezmoi source directory not found at %s\n" "$path" >&2
		return 1
	fi
	printf "%s\n" "$path"
}

creates_named_subdirs() {
	local root="$1"
	shift
	[[ -z "$root" || "$#" -eq 0 ]] && return 1

	mkdir -p "$root"
	for sub in "$@"; do
		mkdir -p "$root/$sub"
	done
}

safe_copy() {
	local src="$1"
	local dest="$2"

	local ddir
	ddir="$(dirname "$dest")"
	mkdir -p "$ddir"
	cp -u "$src" "$dest"
	printf "✅ File '%s' up to date in '%s'\n" "$(basename "$src")" "$dest"
}

main() {
	local chezmoi_dir
	if ! chezmoi_dir=$(get_chezmoi_source_path); then
		return 1
	fi
	creates_named_subdirs "$HOME/.local/share/vim" "backup" "swap" "undo" || return 1
	safe_copy "$chezmoi_dir/chezmoi_config" "$HOME/.config/chezmoi/chezmoi.toml"
	printf "Initial setup complete."
}

main "$@"
