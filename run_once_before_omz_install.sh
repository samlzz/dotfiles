#!/usr/bin/env bash

OMZ_DIR="$HOME/.local/share/oh-my-zsh"
PLUGINS_DIR="$OMZ_DIR/custom/plugins"

declare -A ZSH_PLUGINS=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
  [fast-syntax-highlighting]="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
  [you-should-use]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
)

install_omz()
{
	if [[ ! -d "$OMZ_DIR" ]]; then
		echo "Installing oh-my-zsh in $OMZ_DIR..."
		git clone https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
	else
		echo "oh-my-zsh already installed at $OMZ_DIR"
	fi
}

install_zsh_plugins()
{
	for plugin in "${!ZSH_PLUGINS[@]}"; do
		dest="$PLUGINS_DIR/$plugin"
		if [[ ! -d "$dest" ]]; then
			echo "Installing $plugin → $dest"
			git clone --depth=1 "${ZSH_PLUGINS[$plugin]}" "$dest"
		else
			echo "$plugin already installed."
		fi
	done
}

main()
{
	install_omz && \
		install_zsh_plugins
}

main $@
