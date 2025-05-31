#!/usr/bin/env bash

TPM_DIR="$HOME/.config/tmux/plugins/tpm"

# Permissions
chmod +x ~/.local/bin/*
chmod +x ~/.local/share/ctools/*.sh

# Install tmux plugins (via tpm)
mkdir -p "$(dirname $TPM_DIR)"
if [[ ! -d "$TPM_DIR" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

"$TPM_DIR"/bin/install_plugins
echo "Please ensure all dependecies are installed and $USER is in 'input' group"
