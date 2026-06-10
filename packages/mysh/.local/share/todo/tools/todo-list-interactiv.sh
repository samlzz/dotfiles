#!/usr/bin/env bash

ESC=$'\033'
RESET="${ESC}[0m"
CYAN="36"
BLACK="30"
IT="3"
UD="4"

declare -A CHILDREN
declare -A EXPANDED
declare -a RAW_LINES
declare -a DISPLAYED_LINES
declare -a DISPLAYED_INDEXES
declare TODO_FILE

get_indent_level() {
    local line="$1"
    local indent
    indent=$(sed -E 's/^([[:space:]]*).*$/\1/' <<<"$line" | tr -dc ' ')
    printf "%d" "${#indent}"
}

load_todo_file() {
    local file="$1"
    TODO_FILE="$file"

    local line
    local index=0
    local -a parent_stack=()
    local -a indent_stack=()

    while IFS= read -r line; do
        RAW_LINES+=("$line")

        local indent
        indent=$(get_indent_level "$line")
        local parent=""
        while [[ ${#indent_stack[@]} -gt 0 && ${indent_stack[-1]} -ge $indent ]]; do
            unset 'indent_stack[-1]'
            unset 'parent_stack[-1]'
        done

        if [[ ${#parent_stack[@]} -gt 0 ]]; then
            parent="${parent_stack[-1]}"
            CHILDREN["$parent"]+="$index "
        fi

        indent_stack+=("$indent")
        parent_stack+=("$index")

        if [[ $indent -lt 4 ]]; then
            DISPLAYED_LINES+=("$line")
            DISPLAYED_INDEXES+=("$index")
        fi

        ((index++))
    done <"$file"
}

toggle_checkbox_line() {
    local index="$1"
    local -n lines_ref="$2"
    local line="${lines_ref[$index]}"

    if [[ "$line" =~ ^([[:space:]]*)\[([ xX])\](.*)$ ]]; then
        local prefix="${BASH_REMATCH[1]}"
        local mark="${BASH_REMATCH[2]}"
        local suffix="${BASH_REMATCH[3]}"
        if [[ "$mark" == " " ]]; then
            lines_ref[$index]="${prefix}[x]${suffix}"
        else
            lines_ref[$index]="${prefix}[ ]${suffix}"
        fi
    fi
}

get_all_descendants() {
    local index="$1"
    local -a result=()
    local child

    for child in ${CHILDREN[$index]}; do
        result+=("$child")
        result+=($(get_all_descendants "$child"))
    done

    printf "%s\n" "${result[@]}"
}

toggle_expand_collapse() {
    local display_idx="$1"
    local raw_idx="${DISPLAYED_INDEXES[$display_idx]}"
    local -a new_lines=()
    local -a new_indexes=()

    if [[ -n "${EXPANDED[$raw_idx]}" ]]; then
        # Collapse
        local -A skip=()
        for desc in $(get_all_descendants "$raw_idx"); do
            skip["$desc"]=1
        done

        for ((i = 0; i < ${#DISPLAYED_LINES[@]}; i++)); do
            if [[ $i -eq $display_idx ]]; then
                new_lines+=("${DISPLAYED_LINES[$i]}")
                new_indexes+=("${DISPLAYED_INDEXES[$i]}")
                continue
            fi

            if [[ -z "${skip[${DISPLAYED_INDEXES[$i]}]}" ]]; then
                new_lines+=("${DISPLAYED_LINES[$i]}")
                new_indexes+=("${DISPLAYED_INDEXES[$i]}")
            fi
        done

        unset EXPANDED["$raw_idx"]
    else
        # Expand
        local children="${CHILDREN[$raw_idx]}"
        EXPANDED["$raw_idx"]=1

        for ((i = 0; i <= display_idx; i++)); do
            new_lines+=("${DISPLAYED_LINES[$i]}")
            new_indexes+=("${DISPLAYED_INDEXES[$i]}")
        done

        for child in $children; do
            new_lines+=("${RAW_LINES[$child]}")
            new_indexes+=("$child")
        done

        for ((i = display_idx + 1; i < ${#DISPLAYED_LINES[@]}; i++)); do
            new_lines+=("${DISPLAYED_LINES[$i]}")
            new_indexes+=("${DISPLAYED_INDEXES[$i]}")
        done
    fi

    DISPLAYED_LINES=("${new_lines[@]}")
    DISPLAYED_INDEXES=("${new_indexes[@]}")
}

menu() {
    local -n options_ref=$1
    local selected=0
    local c
    local hilight="${ESC}[${UD};${ESC}[1;${CYAN}m"

    draw_menu() {
        clear
        printf "${hilight}File '$(basename -a -s '.todo' "$TODO_FILE")' todo list:${RESET}\n"
        #printf "${hilight}TODO File Interactive Mode${RESET}\n"
        printf "${ESC}[${IT};${BLACK}mUse ↑↓ to navigate, Space to toggle, Enter to expand/collapse, q to quit.${RESET}\n\n"

        for ((i = 0; i < ${#options_ref[@]}; i++)); do
            local line="${options_ref[$i]}"
            local raw_index="${DISPLAYED_INDEXES[$i]}"

            if [[ $i -eq $selected ]]; then
                if [[ -n "${CHILDREN[$raw_index]}" ]]; then
                    printf "${ESC}[7m>  %s${RESET}\n" "$line"
                else
                    printf "${ESC}[7m> %s${RESET}\n" "$line"
                fi
            else
                if [[ -n "${CHILDREN[$raw_index]}" ]]; then
                    printf " %s\n" "$line"
                else
                    printf "  %s\n" "$line"
                fi
            fi
        done
    }

    stty -icanon -echo
    trap 'stty sane; clear; exit 1' INT TERM

    while true; do
        draw_menu
        IFS= read -rsn1 c
        case "$c" in
        $'\x1b')
            IFS= read -rsn2 -t 0.01 rest
            case "$rest" in
            "[A") selected=$(((selected - 1 + ${#options_ref[@]}) % ${#options_ref[@]})) ;;
            "[B") selected=$(((selected + 1) % ${#options_ref[@]})) ;;
            *)
                stty sane
                return 0
                ;;
            esac
            ;;
        " ")
            toggle_checkbox_line "${DISPLAYED_INDEXES[$selected]}" RAW_LINES
            DISPLAYED_LINES[$selected]="${RAW_LINES[${DISPLAYED_INDEXES[$selected]}]}"
            ;;
        "") # ENTER
            toggle_expand_collapse "$selected"
            ;;
        "q" | "Q")
            stty sane
            return 0
            ;;
        esac
    done
}

save_changes() {
    local tmp_file
    if ! tmp_file=$(mktemp); then
        printf "Error: Failed to create temporary file.\n" >&2
        return 1
    fi

    for line in "${RAW_LINES[@]}"; do
        printf "%s\n" "$line"
    done >"$tmp_file"

    if ! mv -- "$tmp_file" "$TODO_FILE"; then
        printf "Error: Failed to save changes to '%s'.\n" "$TODO_FILE" >&2
        rm -f -- "$tmp_file"
        return 1
    fi
}

main() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        printf "Error: File '%s' not found.\n" "$file" >&2
        return 1
    fi

    load_todo_file "$file"
    menu DISPLAYED_LINES
    save_changes
}

main "$@"
