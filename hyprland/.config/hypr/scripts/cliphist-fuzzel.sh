#!/usr/bin/env bash
# cliphist-fuzzel — clipboard manager with encrypted vault (age + SSH key)
#
# Initial setup: cliphist-fuzzel --setup

FUZZEL_CONFIG="$HOME/.config/fuzzel/clipboard.ini"
FUZZEL_VAULT_CONFIG="$HOME/.config/fuzzel/clipboard-variant.ini"
VAULT_DIR="$HOME/.local/share/cliphist-vault"
SSH_KEY="$HOME/.ssh/id_ed25519"
NOTIFY_TIMEOUT=2000

DEPENDENCIES=(cliphist fuzzel wl-copy age notify-send)

function usage() {
	cat <<EOM

cliphist-fuzzel — clipboard manager with encrypted vault (age + SSH key)

usage: cliphist-fuzzel [--setup | --vault | --help]

options:
    --setup    Initialize the vault (tests encryption/decryption with SSH key)
    --vault    Open vault mode (shows encrypted + normal entries)
    (none)     Open normal clipboard picker

key bindings in fuzzel (exit codes):
    Enter (0)    Copy / decrypt entry
    Delete (10)  Delete entry
	Alt + $ (11) Move entry to/from vault

dependencies: ${DEPENDENCIES[*]}
EOM
	exit 1
}

function main() {
	check_deps

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
	notify "security-high" "cliphist-fuzzel" "Vault initialized successfully\nKey: $SSH_KEY"
}

function cmd_normal() {
	local list
	list=$(cliphist list)

	local filtered=""
	while IFS= read -r line; do
		local hash
		hash=$(entry_hash "$line")
		[[ -f "$VAULT_DIR/$hash.age" ]] && continue
		filtered+="$line"$'\n'
	done <<<"$list"

	local selected
	selected=$(echo "$filtered" | fuzzel --dmenu --with-nth=2 --config "$FUZZEL_CONFIG")
	local exit_code=$?

	echo "exit_code='$exit_code' et selected = '$selected'"
	[[ $exit_code -eq 1 || -z "$selected" ]] && exit 0

	case $exit_code in
	0)
		cliphist decode <<<"$selected" | wl-copy
		notify "edit-paste" "Clipboard" "Entry copied"
		;;
	10)
		cliphist delete <<<"$selected"
		notify "edit-delete" "Clipboard" "Entry deleted"
		;;
	11)
		mask_entry "$selected"
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

	local selected
	selected=$(echo "${vault_entries}${normal_entries}" | fuzzel --dmenu --with-nth=2 --config "$FUZZEL_VAULT_CONFIG")
	local exit_code=$?

	[[ $exit_code -eq 1 || -z "$selected" ]] && exit 0

	if [[ "$selected" == VAULT:* ]]; then
		local hash
		hash=$(echo "$selected" | cut -d: -f2 | cut -f1)
		case $exit_code in
		0)
			unmask_entry "$hash"
			;;
		10)
			rm -f "$VAULT_DIR/$hash.age" "$VAULT_DIR/$hash.label"
			notify "edit-delete" "Clipboard vault" "Entry permanently deleted"
			;;
		11)
			local content
			content=$(age -d -i "$SSH_KEY" "$VAULT_DIR/$hash.age" 2>/dev/null) ||
				die "Decryption failed"
			echo -n "$content" | wl-copy
			# wl-paste will re-add it to cliphist via the daemon
			rm -f "$VAULT_DIR/$hash.age" "$VAULT_DIR/$hash.label"
			notify "security-low" "Clipboard vault" "Entry unmasked and restored"
			;;
		esac
	else
		case $exit_code in
		0)
			cliphist decode <<<"$selected" | wl-copy
			notify "edit-paste" "Clipboard" "Entry copied"
			;;
		10)
			cliphist delete <<<"$selected"
			notify "edit-delete" "Clipboard" "Entry deleted"
			;;
		11)
			mask_entry "$selected"
			;;
		esac
	fi
}

function mask_entry() {
	local entry="$1"

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
	notify "security-high" "Clipboard vault" "Entry hidden and encrypted"
}

function unmask_entry() {
	local hash="$1"
	local vault_file="$VAULT_DIR/$hash.age"

	[[ -f "$vault_file" ]] || die "Vault file not found: $hash"

	local content
	content=$(age -d -i "$SSH_KEY" "$vault_file" 2>/dev/null) ||
		die "Decryption failed — wrong SSH key?"

	echo -n "$content" | wl-copy
	notify "edit-paste" "Clipboard vault" "Entry decrypted and copied"
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
	notify-send -t "$NOTIFY_TIMEOUT" -i "dialog-error" "cliphist-fuzzel" "$1"
	exit 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
	exit 0
fi
