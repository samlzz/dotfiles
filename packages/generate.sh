#!/usr/bin/env bash

PACKAGES_DIR="$(chezmoi source-path)/packages"

mkdir -p "$PACKAGES_DIR"

pacman -Qqe > "$PACKAGES_DIR/pacman.txt"

paru -Qqm > "$PACKAGES_DIR/aur.txt"

snap list | awk 'NR>1 {print $1}' > "$PACKAGES_DIR/snap.txt"

echo "[✔] Dependecies files updated."

