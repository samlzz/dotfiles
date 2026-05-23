#!/usr/bin/env bash
# cliphist-fzf — clipboard manager with encrypted vault (age + SSH key)
#
# Suggested Hyprland binds:
#   bind = $MOD, V,       exec, cliphist-fzf
#   bind = $MOD SHIFT, V, exec, cliphist-fzf --vault
#
# Suggested Hyprland window rules (add to hyprland.conf):
#   windowrulev2 = float,        class:term-float.cliphist-picker
#   windowrulev2 = size 80% 65%, class:term-float.cliphist-picker
#   windowrulev2 = center,       class:term-float.cliphist-picker
#
# Picker key bindings:
#   Enter   → copy / decrypt selected entries
#   Ctrl+D  → delete selected entries
#   Ctrl+S  → move to vault / restore from vault
#   Tab     → toggle multi-select on current entry
#
# Initial setup: cliphist-fzf --setup
# Override terminal: CLIPHIST_TERMINAL=alacritty cliphist-fzf

VAULT_DIR="$HOME/.local/share/cliphist-vault"
SSH_KEY="$HOME/.ssh/id_ed25519"
NOTIFY_TIMEOUT=2000
PICKER_APP_ID="term-float.cliphist-picker"
PICKER_TERMINAL=""
CLIPHIST_TERMINAL="alacritty"

DEPENDENCIES=(cliphist fzf wl-copy age notify-send)

HIGHLIGHT_COLOR='#f9e2af'
HIGHLIGHT_COLOR_VAULT='#f38ba8'

function usage() {
	cat <<EOM

cliphist-fzf — clipboard manager with encrypted vault (age + SSH key)

usage: cliphist-fzf [--setup | --vault | --help]

options:
    --setup    Initialize the vault (tests encryption/decryption with SSH key)
    --vault    Open vault mode (shows encrypted + normal entries)
    (none)     Open normal clipboard picker

picker key bindings:
    Enter     Copy / decrypt selected entry/entries
    Ctrl+D    Delete selected entry/entries
    Ctrl+S    Move to vault / restore from vault
    Tab       Toggle multi-select on current entry

dependencies: ${DEPENDENCIES[*]}

environment:
    CLIPHIST_TERMINAL    Terminal emulator override (auto-detected if unset)
                         Supported: foot, kitty, alacritty, wezterm, ghostty

EOM
	exit 1
}

function main() {
	check_deps
	detect_terminal

	case "${1:-}" in
	--setup) cmd_setup ;;
	--vault) cmd_vault ;;
	--help | -h) usage ;;
	*) cmd_normal ;;
	esac
}

function cmd_setup() {
	[[ -f "$SSH_KEY" ]] || die "SSH key not found: $SSH_KEY"
	[[ -f "$SSH_KEY.pub" ]] || die "SSH public key not found: $SSH_KEY.pub"

	mkdir -p "$VAULT_DIR"
	chmod 700 "$VAULT_DIR"

	local test_plain="cliphist-vault-test"
	local test_file="$VAULT_DIR/.setup-test.age"

	echo "$test_plain" | age -R "$SSH_KEY.pub" -o "$test_file" ||
		die "Encryption test failed with SSH key"

	local decrypted
	decrypted=$(age -d -i "$SSH_KEY" "$test_file" 2>/dev/null) ||
		die "Decryption test failed — SSH key not recognized by age"

	[[ "$decrypted" == "$test_plain" ]] ||
		die "Decryption output mismatch"

	rm -f "$test_file"
	notify "security-high" "cliphist-fzf" "Vault initialized successfully\nKey: $SSH_KEY"
}

function cmd_normal() {
	local list
	list=$(cliphist list)

	local filtered
	if ! compgen -G "$VAULT_DIR/*.age" >/dev/null 2>&1; then
		# Fast path: vault is empty, nothing to filter
		filtered="$list"
	else
		# Batch-compute all hashes in a single Python call instead of N×sha256sum
		local -a entries hashes
		mapfile -t entries <<<"$list"
		mapfile -t hashes < <(
			printf '%s\n' "${entries[@]}" |
				python3 -c "
import sys, hashlib
for line in sys.stdin:
    print(hashlib.sha256(line.rstrip('\n').encode()).hexdigest()[:16])
"
		)
		filtered=""
		for i in "${!entries[@]}"; do
			[[ -n "${entries[i]}" ]] || continue
			[[ -f "$VAULT_DIR/${hashes[i]}.age" ]] && continue
			filtered+="${entries[i]}"$'\n'
		done
	fi

	run_picker "$filtered" "normal"
	[[ ${#PICKER_ENTRIES[@]} -eq 0 ]] && exit 0

	local count=${#PICKER_ENTRIES[@]}
	local lbl
	((count == 1)) && lbl="entry" || lbl="entries"

	case "$PICKER_KEY" in
	"")
		for entry in "${PICKER_ENTRIES[@]}"; do
			cliphist decode <<<"$entry"
		done | wl-copy
		notify "edit-paste" "Clipboard" "$count $lbl copied"
		;;
	ctrl-d)
		for entry in "${PICKER_ENTRIES[@]}"; do
			cliphist delete <<<"$entry"
		done
		notify "edit-delete" "Clipboard" "$count $lbl deleted"
		;;
	ctrl-s)
		for entry in "${PICKER_ENTRIES[@]}"; do
			mask_entry "$entry" silent
		done
		notify "security-high" "Clipboard vault" "$count $lbl encrypted"
		;;
	esac
}

function cmd_vault() {
	local vault_entries=""

	for label_file in "$VAULT_DIR"/*.label; do
		[[ -f "$label_file" ]] || continue
		local hash
		hash=$(basename "$label_file" .label)
		local label
		label=$(cat "$label_file")
		vault_entries+="VAULT:$hash	 $label"$'\n'
	done

	local normal_entries
	normal_entries=$(cliphist list)

	run_picker "${vault_entries}${normal_entries}" "vault"
	[[ ${#PICKER_ENTRIES[@]} -eq 0 ]] && exit 0

	local count=${#PICKER_ENTRIES[@]}
	local lbl
	((count == 1)) && lbl="entry" || lbl="entries"

	case "$PICKER_KEY" in
	"")
		for entry in "${PICKER_ENTRIES[@]}"; do
			if [[ "$entry" == VAULT:* ]]; then
				local hash
				hash=$(echo "$entry" | cut -d: -f2 | cut -f1)
				age -d -i "$SSH_KEY" "$VAULT_DIR/$hash.age" 2>/dev/null ||
					{
						notify-send -i "dialog-error" "Clipboard vault" "Decryption failed"
						continue
					}
			else
				cliphist decode <<<"$entry"
			fi
		done | wl-copy
		notify "edit-paste" "Clipboard vault" "$count $lbl copied"
		;;
	ctrl-d)
		for entry in "${PICKER_ENTRIES[@]}"; do
			if [[ "$entry" == VAULT:* ]]; then
				local hash
				hash=$(echo "$entry" | cut -d: -f2 | cut -f1)
				rm -f "$VAULT_DIR/$hash.age" "$VAULT_DIR/$hash.label"
			else
				cliphist delete <<<"$entry"
			fi
		done
		notify "edit-delete" "Clipboard vault" "$count $lbl deleted"
		;;
	ctrl-s)
		for entry in "${PICKER_ENTRIES[@]}"; do
			if [[ "$entry" == VAULT:* ]]; then
				local hash
				hash=$(echo "$entry" | cut -d: -f2 | cut -f1)
				local content
				content=$(age -d -i "$SSH_KEY" "$VAULT_DIR/$hash.age" 2>/dev/null) ||
					{
						notify-send -i "dialog-error" "Clipboard vault" "Decryption failed"
						continue
					}
				echo -n "$content" | wl-copy
				# wl-paste will re-add it to cliphist via the daemon
				rm -f "$VAULT_DIR/$hash.age" "$VAULT_DIR/$hash.label"
			else
				mask_entry "$entry" silent
			fi
		done
		notify "security-low" "Clipboard vault" "$count $lbl toggled"
		;;
	esac
}

PICKER_KEY=""
PICKER_ENTRIES=()

function run_picker() {
	local entries="$1"
	local mode="${2:-normal}"
	PICKER_KEY=""
	PICKER_ENTRIES=()

	# Prompt, header (2 lines), and optional color override per mode
	local prompt header color_flag
	if [[ "$mode" == "vault" ]]; then
		prompt=' Vault  '
		header=$'Tab: multi-select  Enter: copy \nCtrl+D: delete  Ctrl+S: restore/vault'
		color_flag="    --color='prompt:$HIGHLIGHT_COLOR_VAULT,border:$HIGHLIGHT_COLOR_VAULT,header:$HIGHLIGHT_COLOR_VAULT' \\"$'\n'
	else
		prompt='  Clipboard  '
		header=$'Tab: multi-select  Enter: copy \nCtrl+D: delete  Ctrl+S: vault'
		color_flag="    --color='prompt:$HIGHLIGHT_COLOR,border:$HIGHLIGHT_COLOR,header:$HIGHLIGHT_COLOR' \\"$'\n'
	fi

	local tmpdir
	tmpdir=$(mktemp -d)

	printf '%s' "$entries" >"$tmpdir/input"

	# Preview script: decode normal entries, show label for vault entries.
	# VAULT_DIR is embedded at generation time.
	cat >"$tmpdir/preview.sh" <<PREVIEW_EOF
#!/usr/bin/env bash
entry="\$1"
if [[ "\$entry" == VAULT:* ]]; then
    hash=\$(echo "\$entry" | cut -d: -f2 | cut -f1)
    printf '\033[33m[Encrypted vault entry]\033[0m\n\n'
    label_file="${VAULT_DIR}/\$hash.label"
    [[ -f "\$label_file" ]] && cat "\$label_file"
else
    echo "\$entry" | cliphist decode 2>/dev/null \
        || printf '\033[31m[Binary content — cannot preview]\033[0m\n'
fi
PREVIEW_EOF
	chmod +x "$tmpdir/preview.sh"

	cat >"$tmpdir/picker.sh" <<PICKER_EOF
#!/usr/bin/env bash
fzf \\
    --multi \\
    --delimiter='\t' \\
    --with-nth=2.. \\
    --preview='$tmpdir/preview.sh {}' \\
    --preview-window='right:60%:wrap' \\
    --expect='ctrl-d,ctrl-s' \\
    --border=rounded \\
    --layout=reverse \\
    --prompt='$prompt' \\
    --pointer='▶' \\
    --marker='✓' \\
    --header='$header' \\
${color_flag}    < '$tmpdir/input' > '$tmpdir/output'
PICKER_EOF
	chmod +x "$tmpdir/picker.sh"

	launch_terminal "$tmpdir/picker.sh"

	if [[ -f "$tmpdir/output" ]]; then
		PICKER_KEY=$(head -1 "$tmpdir/output")
		mapfile -t PICKER_ENTRIES < <(tail -n +2 "$tmpdir/output")
		# Drop trailing empty entries that mapfile may append
		while [[ ${#PICKER_ENTRIES[@]} -gt 0 && -z "${PICKER_ENTRIES[-1]}" ]]; do
			unset 'PICKER_ENTRIES[-1]'
		done
	fi

	rm -rf "$tmpdir"
}

function launch_terminal() {
	local script="$1"
	case "$PICKER_TERMINAL" in
	foot) foot --app-id="$PICKER_APP_ID" -e bash "$script" ;;
	kitty) kitty --class="$PICKER_APP_ID" bash "$script" ;;
	alacritty) alacritty --class "$PICKER_APP_ID" -e bash "$script" ;;
	wezterm) wezterm start --class "$PICKER_APP_ID" -- bash "$script" ;;
	ghostty) ghostty --class="$PICKER_APP_ID" -e bash "$script" ;;
	xterm) xterm -class "$PICKER_APP_ID" -e bash "$script" ;;
	*) die "Unsupported terminal: $PICKER_TERMINAL" ;;
	esac
}

function detect_terminal() {
	if [[ -n "${CLIPHIST_TERMINAL:-}" ]]; then
		PICKER_TERMINAL="$CLIPHIST_TERMINAL"
		return
	fi
	local candidates=(foot kitty alacritty wezterm ghostty xterm)
	for t in "${candidates[@]}"; do
		if command -v "$t" &>/dev/null; then
			PICKER_TERMINAL="$t"
			return
		fi
	done
	die "No supported terminal found (tried: ${candidates[*]})"
}

function mask_entry() {
	local entry="$1"
	local silent="${2:-}"

	local content
	content=$(cliphist decode <<<"$entry") || die "Failed to decode entry"

	local hash
	hash=$(entry_hash "$entry")
	local vault_file="$VAULT_DIR/$hash.age"

	echo "$content" | age -R "$SSH_KEY.pub" -o "$vault_file" ||
		die "Encryption failed"

	local label
	label=$(echo "$entry" | cut -f2- | head -c 60)
	echo "$label" >"$VAULT_DIR/$hash.label"

	cliphist delete <<<"$entry"
	[[ -z "$silent" ]] && notify "security-high" "Clipboard vault" "Entry hidden and encrypted"
}

function entry_hash() {
	echo -n "$1" | sha256sum | cut -c1-16
}

function check_deps() {
	local missing=()
	for cmd in "${DEPENDENCIES[@]}"; do
		command -v "$cmd" &>/dev/null || missing+=("$cmd")
	done
	[[ ${#missing[@]} -gt 0 ]] && die "Missing dependencies: ${missing[*]}"
	mkdir -p "$VAULT_DIR"
}

function notify() {
	local icon="$1" title="$2" msg="$3"
	notify-send -t "$NOTIFY_TIMEOUT" -i "$icon" "$title" "$msg"
}

function die() {
	notify-send -t "$NOTIFY_TIMEOUT" -i "dialog-error" "cliphist-fzf" "$1"
	exit 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
	exit 0
fi
