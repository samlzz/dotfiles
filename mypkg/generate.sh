#!/usr/bin/env bash

PACKAGES_DIR="$HOME/dotfiles/mypkg"

mkdir -p "$PACKAGES_DIR"

pacman -Qqe >"$PACKAGES_DIR/pacman.txt"

paru -Qqm >"$PACKAGES_DIR/aur.txt"

flatpak list --app | awk '{ print $2 }' >"$PACKAGES_DIR/flatpak.txt"

echo "[✔] Dependecies files updated."
