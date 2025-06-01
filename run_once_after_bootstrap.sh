#!/usr/bin/env bash

TPM_DIR="$HOME/.config/tmux/plugins/tpm"

# 🔐 Scripts permissions
chmod +x ~/.local/bin/* 2>/dev/null
chmod +x ~/.local/share/ctools/*.sh 2>/dev/null

# 📦 Install tmux plugins (via tpm)
mkdir -p "$(dirname "$TPM_DIR")"
if [[ ! -d "$TPM_DIR" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

"$TPM_DIR"/bin/install_plugins

echo "Initial setup complete. Please ensure all dependencies are installed."

