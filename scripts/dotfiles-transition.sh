#!/usr/bin/env bash
# dotfiles-transition.sh
# Iterates over a stow package directory and helps you remove the "real"
# counterpart of each file so that stow can create its symlinks cleanly.
#
# Usage: dotfiles-transition.sh <package-dir>
# Deps : fzf, delta, $EDITOR (nvim fallback)

set -euo pipefail
IFS=$'\n\t'

export HOME="/tmp/home-dotfiles-test"

# ─────────────────────────────────────────────────────────────────────────────
# Constants & globals
# ─────────────────────────────────────────────────────────────────────────────

readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-transition/transition-$(date +%F_%H-%M-%S).log"
readonly EDITOR="${EDITOR:-nvim}"

# Search roots (order matters: most specific first)
readonly SEARCH_ROOTS=(
    "$HOME/.config"
    "$HOME/.local/share"
    "$HOME/.local/state"
    "$HOME/.local/bin"
)

# Colours
readonly C_RESET='\033[0m'
readonly C_BOLD='\033[1m'
readonly C_RED='\033[0;31m'
readonly C_GREEN='\033[0;32m'
readonly C_YELLOW='\033[0;33m'
readonly C_CYAN='\033[0;36m'
readonly C_DIM='\033[2m'

# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────

_ensure_log_dir() {
    mkdir -p "$(dirname "$LOG_FILE")"
}

# log <ACTION> <message>
log() {
    local action="$1"
    local message="$2"
    local timestamp
    timestamp="$(date '+%F %T')"
    printf '[%s] {%s} %s\n' "$timestamp" "$action" "$message" | tee -a "$LOG_FILE"
}

# ─────────────────────────────────────────────────────────────────────────────
# UI helpers
# ─────────────────────────────────────────────────────────────────────────────

info()    { printf "${C_CYAN}${C_BOLD}  ==> ${C_RESET}${C_BOLD}%s${C_RESET}\n" "$*"; }
success() { printf "${C_GREEN}${C_BOLD}  ✓   ${C_RESET}%s\n" "$*"; }
warn()    { printf "${C_YELLOW}${C_BOLD}  !   ${C_RESET}%s\n" "$*"; }
err()     { printf "${C_RED}${C_BOLD}  ✗   ${C_RESET}%s\n" "$*" >&2; }
dim()     { printf "${C_DIM}       %s${C_RESET}\n" "$*"; }

# print_separator <label>
print_separator() {
    local label="${1:-}"
    local width=72
    printf '\n%s\n' "$(printf '─%.0s' $(seq 1 $width))"
    [[ -n "$label" ]] && printf ' %s\n' "$label"
    printf '%s\n\n' "$(printf '─%.0s' $(seq 1 $width))"
}

# prompt_choice <prompt> <option1> <option2> ...  → echoes chosen option letter (lowercase)
prompt_choice() {
    local prompt="$1"; shift
    local options=("$@")
    local joined
    joined="$(IFS='/'; echo "${options[*]}")"
    local answer
    while true; do
        printf "${C_BOLD}%s [%s]: ${C_RESET}" "$prompt" "$joined" >/dev/tty
        read -r answer </dev/tty
        answer="$(echo "$answer" | tr '[:upper:]' '[:lower:]')"
        for opt in "${options[@]}"; do
            local lowOpt
            lowOpt="$(echo "$opt" | tr '[:upper:]' '[:lower:]')"
            [[ "$answer" == "$lowOpt" ]] && { echo "$answer"; return 0; }
        done
        printf "${C_YELLOW}${C_BOLD}  !   ${C_RESET}Invalid choice. Please enter one of: %s\n" "$joined" >/dev/tty
    done
}
# ─────────────────────────────────────────────────────────────────────────────
# Dependency check
# ─────────────────────────────────────────────────────────────────────────────

check_deps() {
    local missing=()
    for cmd in fzf delta find diff; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if (( ${#missing[@]} > 0 )); then
        err "Missing required dependencies: ${missing[*]}"
        err "Install them and retry."
        exit 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# File search
# ─────────────────────────────────────────────────────────────────────────────

# find_real_file <filename> → prints matching path(s), one per line
find_real_file() {
    local filename="$1"
    local results=()

    # 1. Search in XDG roots (no depth limit)
    for root in "${SEARCH_ROOTS[@]}"; do
        [[ -d "$root" ]] || continue
        while IFS= read -r match; do
            results+=("$match")
        done < <(find "$root" -name "$filename" 2>/dev/null)
    done

    # 2. Search directly in HOME (maxdepth 1, hidden + visible)
    while IFS= read -r match; do
        results+=("$match")
    done < <(find "$HOME" -maxdepth 1 -name "$filename" 2>/dev/null)

    # Deduplicate and print
    (( ${#results[@]} > 0 )) && printf '%s\n' "${results[@]}" | sort -u || true
}

# ─────────────────────────────────────────────────────────────────────────────
# Directory cleanup
# ─────────────────────────────────────────────────────────────────────────────

# maybe_remove_empty_dir <dir>
maybe_remove_empty_dir() {
    local dir="$1"

    # Never remove HOME or XDG roots themselves
    local protected=(
        "$HOME"
        "$HOME/.config"
        "$HOME/.local"
        "$HOME/.local/share"
        "$HOME/.local/state"
        "$HOME/.local/bin"
    )
    for p in "${protected[@]}"; do
        [[ "$dir" == "$p" ]] && return 0
    done

    # Check if dir is empty (ignoring hidden entries is intentional — we want
    # to count everything)
    if [[ -d "$dir" ]] && [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
        warn "Directory is now empty: ${dir}"
        local choice
        choice="$(prompt_choice "Remove empty directory?" y n)"
        case "$choice" in
            d)
                rm -rf "$dir"
                log "RMDIR" "$dir"
                success "Removed empty directory: ${dir}"
                # Recurse upward
                maybe_remove_empty_dir "$(dirname "$dir")"
                ;;
            s)
                log "SKIP_RMDIR" "$dir"
                dim "Kept empty directory: ${dir}"
                ;;
        esac
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Core: handle one file
# ─────────────────────────────────────────────────────────────────────────────

# remove_real_file <real_path>
remove_real_file() {
    local real="$1"
    local parent_dir
    parent_dir="$(dirname "$real")"

    rm -f "$real"
    log "DELETE" "$real"
    success "Deleted: ${real}"

    maybe_remove_empty_dir "$parent_dir"
}

# handle_diff <source_file> <real_file>
# Returns 0 when the file has been dealt with (deleted or skipped).
handle_diff() {
    local source="$1"
    local real="$2"

    while true; do
        print_separator "DIFF  source ← dotfiles  |  target ← system"
        dim "source : $source"
        dim "target : $real"
        printf '\n'

        # Show diff via delta
        delta "$source" "$real" || true
        printf '\n'

        warn "Files differ."
        local choice
        choice="$(prompt_choice \
            "  [e] Edit source  [d] Delete system (keep dotfiles)  [o] Overwrite dotfiles with system  [s] Skip" \
            e d o s)"

        case "$choice" in
            e)
                "$EDITOR" "$source"
                # Re-evaluate after edit
                if diff -q "$source" "$real" &>/dev/null; then
                    log "EDIT" "$source"
                    success "Files are now identical after edit."
                    remove_real_file "$real"
                    return 0
                else
                    info "Files still differ — showing updated diff."
                    # Loop again
                fi
                ;;
            d)
                log "DELETE_DESPITE_DIFF" "$real"
                remove_real_file "$real"
                return 0
                ;;
            o)
                cp "$real" "$source"
                log "OVERWRITE_SOURCE" "$source <- $real"
                success "Dotfiles source overwritten with system file: ${source}"
                remove_real_file "$real"
                return 0
                ;;
            s)
                log "SKIP" "$real"
                dim "Skipped: ${real}"
                return 0
                ;;
        esac
    done
}

# process_source_file <source_file> <package_root>
process_source_file() {
    local source="$1"
    local pkg_root="$2"
    local filename
    filename="$(basename "$source")"

    print_separator "FILE  ${filename}"
    dim "dotfiles source: $source"

    # ── Find real counterpart(s) ──────────────────────────────────────────
    local -a matches
    mapfile -t matches < <(find_real_file "$filename")

    local real_file=""

    if (( ${#matches[@]} == 0 )); then
        warn "No system file found for '${filename}'."
        log "NOT_FOUND" "$filename"

        # Let user pick manually via fzf
        info "Use fzf to locate the file (or press Escape to skip)."
        real_file="$(find "$HOME" -maxdepth 8 2>/dev/null \
            | fzf --prompt="Locate ${filename} > " \
                  --preview='[[ -f {} ]] && bat --color=always {} || ls -la {}' \
                  --height=60% --layout=reverse \
                  --header="Select the real path for '${filename}', or Escape to skip" \
            || true)"

        if [[ -z "$real_file" ]]; then
            log "SKIPPED_NOT_FOUND" "$filename"
            dim "Skipped (not found, user aborted fzf)."
            return 0
        fi

    elif (( ${#matches[@]} == 1 )); then
        real_file="${matches[0]}"
        dim "Found: $real_file"

    else
        # Multiple matches → let user pick
        warn "Multiple matches found for '${filename}':"
        printf '%s\n' "${matches[@]}" | while read -r m; do dim "  $m"; done
        real_file="$(printf '%s\n' "${matches[@]}" \
            | fzf --prompt="Select the correct file > " \
                  --preview='bat --color=always {}' \
                  --height=40% --layout=reverse \
                  --header="Multiple matches for '${filename}' — pick the right one" \
            || true)"

        if [[ -z "$real_file" ]]; then
            log "SKIPPED_MULTI" "$filename"
            dim "Skipped (user aborted fzf on multiple matches)."
            return 0
        fi
    fi

    # ── Skip symlinks already pointing into dotfiles ──────────────────────
    if [[ -L "$real_file" ]]; then
        local link_target
        link_target="$(readlink -f "$real_file" 2>/dev/null || true)"
        if [[ "$link_target" == "$pkg_root"* ]]; then
            log "ALREADY_STOWED" "$real_file"
            success "Already stowed, skipping: ${real_file}"
            return 0
        fi
    fi

    # ── Compare & act ─────────────────────────────────────────────────────
    if diff -q "$source" "$real_file" &>/dev/null; then
        log "IDENTICAL_DELETE" "$real_file"
        success "Identical — deleting system file: ${real_file}"
        remove_real_file "$real_file"
    else
        handle_diff "$source" "$real_file"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} <package-dir>

  Iterates recursively over every file in <package-dir> (a stow package),
  finds its real counterpart on the system, diffs it, and helps you remove
  the system copy so stow can create the symlink.

Options:
  -h, --help    Show this help message.

Dependencies: fzf, delta, \$EDITOR (default: nvim)
EOF
}

main() {
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        usage
        exit 0
    fi

    local pkg_dir="${1%/}"   # strip trailing slash

    if [[ ! -d "$pkg_dir" ]]; then
        err "Not a directory: '${pkg_dir}'"
        exit 1
    fi

    local pkg_root
    pkg_root="$(realpath "$pkg_dir")"

    check_deps
    _ensure_log_dir

    info "Starting dotfiles transition for package: ${pkg_root}"
    info "Log file: ${LOG_FILE}"
    log "START" "package=${pkg_root}"

    local processed=0
    local skipped=0

    # Iterate over every regular file (and symlinks) inside the package
    while IFS= read -r source_file; do
        # Skip git internals if the package is inside the dotfiles repo
        [[ "$source_file" == *"/.git/"* ]] && continue

        process_source_file "$source_file" "$pkg_root"
        (( processed++ )) || true

    done < <(find "$pkg_root" \( -type f -o -type l \) | sort)

    print_separator "DONE"
    log "DONE" "processed=${processed}"
    info "All files processed."
    dim "Full log: ${LOG_FILE}"
}

main "$@"
