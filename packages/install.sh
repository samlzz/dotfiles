#!/usr/bin/env bash

set -e
PACKAGES_DIR="$(chezmoi source-path)/packages"

main() {
	local pacman_file="$PACKAGES_DIR/pacman.txt"
	local aur_file="$PACKAGES_DIR/aur.txt"
	local snap_file="$PACKAGES_DIR/snap.txt"

	if [ -f "$pacman_file" ]; then
		echo "[+] Install pacman packages…"
		sudo pacman -S --needed - < "$PACKAGES_DIR"/pacman.txt
	fi

	if [ -f "$aur_file" ]; then
		echo "[+] Install AUR packages…"
		paru -S --needed - < "$PACKAGES_DIR"/aur.txt
	fi

	if [ -f "$snap_file" ]; then
		echo "[+] Install snap packages…"
		while read -r snap; do
		    sudo snap install "$snap" || true
		done < "$PACKAGES_DIR"/snap.txt
	fi
}
main $@
