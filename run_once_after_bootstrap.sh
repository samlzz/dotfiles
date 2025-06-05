#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

TPM_DIR="$HOME/.config/tmux/plugins/tpm"
TARGET_DIR="/usr/local/bin"
declare -A HYPR_PLUGINS=(
	['split-monitor-workspaces']="https://github.com/Duckonaut/split-monitor-workspaces"
	# ['autre-plugin']="https://github.com/user/autre-plugin"
)

install_hyprland_plugins() {
	if ! command -v hyprpm &>/dev/null; then
		printf "❌ hyprpm absent. Skipping Hyprland plugins.\n" >&2
		return 0
	fi

	hyprpm update

	for plugin in "${!HYPR_PLUGINS[@]}"; do
		local url="${HYPR_PLUGINS[$plugin]}"

		if ! hyprpm list | grep -q "$plugin"; then
			printf "➕ Adding Hyprland plugin %s\n" "$plugin"
			hyprpm add "$url"
		else
			printf "✅ Plugin %s already present\n" "$plugin"
		fi

		hyprpm enable "$plugin"
	done

	hyprpm reload
}

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

install_tmux_plugins() {
	mkdir -p "$(dirname "$TPM_DIR")"
	if [[ ! -d "$TPM_DIR" ]]; then
		if ! git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" >&2; then
			printf "Error: failed to clone TPM\n" >&2
			return 1
		fi
	fi
	if ! "$TPM_DIR/bin/install_plugins" >&2; then
		printf "Error: failed to install tmux plugins\n" >&2
		return 1
	fi
}

show_conflict_dates() {
	local src=$1
	local dest=$2

	local src_date dest_date
	if ! src_date=$(stat -c %y "$src" 2>/dev/null); then
		printf "Error: cannot stat %s\n" "$src" >&2
		return 1
	fi
	if ! dest_date=$(stat -c %y "$dest" 2>/dev/null); then
		printf "Error: cannot stat %s\n" "$dest" >&2
		return 1
	fi

	printf "⚠️  Conflict detected:\n"
	printf "  📦 chezmoi : %s\n" "$src_date"
	printf "  📍 system  : %s\n" "$dest_date"
}

apply_executable_decision() {
	local src=$1
	local dest=$2

	if cmp -s "$src" "$dest"; then
		printf "✅ %s is already up to date\n" "$dest"
		return
	fi

	show_conflict_dates "$src" "$dest" || return 1

	printf "What do you want to do?\n"
	printf "  [1] Overwrite system file (%s)\n" "$dest"
	printf "  [2] Overwrite chezmoi file (%s)\n" "$src"
	printf "  [3] Skip\n"
	local choice
	read -rp "Choice [1/2/3]: " choice

	case "$choice" in
	1)
		printf "↪️  Copying %s → %s\n" "$src" "$dest"
		sudo install -m 755 "$src" "$dest"
		;;
	2)
		printf "↩️  Copying %s → %s\n" "$dest" "$src"
		cp "$dest" "$src"
		;;
	*)
		printf "⏩ Skipped\n"
		;;
	esac
}

install_usr_executables() {
	local chezmoi_dir
	if ! chezmoi_dir=$(get_chezmoi_source_path); then
		return 1
	fi

	shopt -s nullglob
	local cur_dir
	cur_dir=$(pwd)
	cd "$chezmoi_dir" || return 1

	local src dest_name dest
	for src in executable_*; do
		dest_name="${src#executable_}"
		dest="$TARGET_DIR/$dest_name"

		if [[ ! -e "$dest" ]]; then
			printf "⭐ %s does not exist. Installing…\n" "$dest"
			sudo install -m 755 "$src" "$dest"
			continue
		fi

		apply_executable_decision "$src" "$dest"
	done

	cd "$cur_dir" || return 1
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

main() {
	install_tmux_plugins || return 1
	install_usr_executables || return 1
	install_hyprland_plugins || return 1
	creates_named_subdirs "$HOME/.local/share/vim" "backup" "swap" "undo" || return 1
	printf "Initial setup complete. Make sure all required dependencies are installed.\n"
}

main "$@"
