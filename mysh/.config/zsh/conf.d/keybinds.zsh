### ─────────────────────────────────────────────────────────────
### Buffer line editor
### ─────────────────────────────────────────────────────────────
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^g' edit-command-line

### ─────────────────────────────────────────────────────────────
### Undo / Redo
### ─────────────────────────────────────────────────────────────

bindkey '^Xu' undo

bindkey '^Xr' redo

### ─────────────────────────────────────────────────────────────
### Copy current command
### ─────────────────────────────────────────────────────────────
copy-command() {
	echo -n "$BUFFER" | wl-copy
	zle -M "Copied to clipboard"
}
zle -N copy-command
bindkey '^Xc' copy-command
