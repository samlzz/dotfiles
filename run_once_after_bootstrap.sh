#!/usr/bin/env bash

TPM_DIR="$HOME/.config/tmux/plugins/tpm"
OMZ_DIR="$HOME/.local/share/oh-my-zsh"

# 🔐 Scripts permissions
chmod +x ~/.local/bin/* 2>/dev/null
chmod +x ~/.local/share/ctools/*.sh 2>/dev/null

# 📦 Install tmux plugins (via tpm)
mkdir -p "$(dirname "$TPM_DIR")"
if [[ ! -d "$TPM_DIR" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

"$TPM_DIR"/bin/install_plugins

# 🧠 Install oh-my-zsh (XDG-compliant path)
if [[ ! -d "$OMZ_DIR" ]]; then
  echo "Installing oh-my-zsh in $OMZ_DIR..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
else
  echo "oh-my-zsh already installed at $OMZ_DIR"
fi

echo "Initial setup complete. Please ensure all dependencies are installed."

