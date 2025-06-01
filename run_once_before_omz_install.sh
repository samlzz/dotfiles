#!/usr/bin/env bash

OMZ_DIR="$HOME/.local/share/oh-my-zsh"

if [[ ! -d "$OMZ_DIR" ]]; then
  echo "Installing oh-my-zsh in $OMZ_DIR..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
else
  echo "oh-my-zsh already installed at $OMZ_DIR"
fi

