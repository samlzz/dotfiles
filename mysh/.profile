### ─────────────────────────────────────────────────────────────
### XDG Environment Variables
### ─────────────────────────────────────────────────────────────

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

### ─────────────────────────────────────────────────────────────
### Pager config
### ─────────────────────────────────────────────────────────────

export COLORTERM=truecolor

export LESS='--mouse --wheel-lines=3 -RF'
export PAGER='less'

# Use bat as manpager with stripped ANSI
if command -v bat &> /dev/null; then
  export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
else
  export MANPAGER='less -R'
fi

### ─────────────────────────────────────────────────────────────
### Editor config
### ─────────────────────────────────────────────────────────────

if command -v nvim &> /dev/null; then
  export EDITOR=nvim
elif command -v vim &> /dev/null; then
  export EDITOR=vim
else
  export EDITOR=nano
fi
