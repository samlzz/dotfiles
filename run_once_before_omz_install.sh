#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t' #? remove space splitting

OMZ_DIR="$HOME/.local/share/oh-my-zsh"
PLUGINS_DIR="$OMZ_DIR/custom/plugins"

declare -A ZSH_PLUGINS=(
	['zsh-autosuggestions']="https://github.com/zsh-users/zsh-autosuggestions.git"
	['zsh-syntax-highlighting']="https://github.com/zsh-users/zsh-syntax-highlighting.git"
	['fast-syntax-highlighting']="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
	['you-should-use']="https://github.com/MichaelAquilina/zsh-you-should-use.git"
)

install_oh_my_zsh() {
	if [[ ! -d "$OMZ_DIR" ]]; then
		printf "Installing oh-my-zsh into %s...\n" "$OMZ_DIR"
		if ! git clone https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR" >&2; then
			printf "Error: failed to clone oh-my-zsh repository\n" >&2
			return 1
		fi
	else
		printf "oh-my-zsh already installed at %s\n" "$OMZ_DIR"
	fi
}

install_plugin() {
	local name=$1
	local url=$2
	local dest="$PLUGINS_DIR/$name"

	if [[ ! "$name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
		printf "Error: invalid plugin name: %s\n" "$name" >&2
		return 1
	fi

	if [[ ! "$url" =~ ^https://github\.com/[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+\.git$ ]]; then
		printf "Error: invalid plugin URL: %s\n" "$url" >&2
		return 1
	fi

	if [[ ! -d "$dest" ]]; then
		printf "Installing plugin %s → %s\n" "$name" "$dest"
		if ! git clone --depth=1 "$url" "$dest" >&2; then
			printf "Error: failed to clone %s from %s\n" "$name" "$url" >&2
			return 1
		fi
	else
		printf "Plugin %s already installed at %s\n" "$name" "$dest"
	fi
}

install_all_plugins() {
	mkdir -p "$PLUGINS_DIR"

	local plugin
	for plugin in "${!ZSH_PLUGINS[@]}"; do
		install_plugin "$plugin" "${ZSH_PLUGINS[$plugin]}"
	done
}

main() {
	install_oh_my_zsh || return 1
	install_all_plugins || return 1
}

main "$@"
