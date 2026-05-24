[[ ! "$XDG_DATA_HOME/zsh" ]] && mkdir "$XDG_DATA_HOME/zsh"
[[ ! "$XDG_STATE_HOME/zsh" ]] && mkdir "$XDG_STATE_HOME/zsh"
[[ ! "$XDG_CACHE_HOME/zsh" ]] && mkdir "$XDG_CACHE_HOME/zsh"

### ─────────────────────────────────────────────────────────────
### Plugins
### ─────────────────────────────────────────────────────────────
plugins=(
  you-should-use
  zsh-syntax-highlighting
  fast-syntax-highlighting
  zsh-autosuggestions
  fzf-tab
)

### ─────────────────────────────────────────────────────────────
### Oh-My-Zsh / Completion Setting
### ─────────────────────────────────────────────────────────────
source "$ZSH/oh-my-zsh.sh"

CASE_SENSITIVE="true"
ALWAYS_TO_END="true"
COMPLETION_WAITING_DOTS="true"

zstyle ':omz:update' mode auto
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

### ─────────────────────────────────────────────────────────────
### Zsh History
### ─────────────────────────────────────────────────────────────
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

setopt INC_APPEND_HISTORY_TIME
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

### ─────────────────────────────────────────────────────────────
### Oh-My-Posh Configuration
### ─────────────────────────────────────────────────────────────
eval "$($HOME/.local/bin/oh-my-posh init zsh --config $XDG_CONFIG_HOME/ohmyposh/mocha_zen.toml)"

### ─────────────────────────────────────────────────────────────
### CLI Tools Initialization
### ─────────────────────────────────────────────────────────────

# Zoxide (cd alternative)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Use trashcli to rm files 10 minutes later
if command -v trash-put &> /dev/null; then
  del() {
    trash-put "$@" && \
	    systemd-run --user --on-active=10min trash-empty 0.007 &> /dev/null
  }

  restore() {
    mv "$XDG_DATA_HOME/Trash/files/$1" .
  }
fi

### ─────────────────────────────────────────────────────────────
### Completion
### ─────────────────────────────────────────────────────────────
SITE_FUNCTIONS="$XDG_DATA_HOME/zsh/site-functions"
fpath+=("$SITE_FUNCTIONS")
autoload -Uz compinit && compinit -d "$ZSH_COMPDUMP"

[[ -f "$SITE_FUNCTIONS/custom_completion.zsh" ]] && source "$SITE_FUNCTIONS/custom_completion.zsh"

# For rm_secure
autoload -Uz complist
zmodload zsh/complist

### ─────────────────────────────────────────────────────────────
### Load sub config
### ─────────────────────────────────────────────────────────────
for f in "$XDG_CONFIG_HOME"/zsh/conf.d/*; do
    source "$f"
done

### ─────────────────────────────────────────────────────────────
### nvm configuration
### ─────────────────────────────────────────────────────────────
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.config/nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
source /usr/share/nvm/init-nvm.sh

### ─────────────────────────────────────────────────────────────
### Rust configuration
### ─────────────────────────────────────────────────────────────
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"

### ─────────────────────────────────────────────────────────────
### Sui configuration
### ─────────────────────────────────────────────────────────────
export SUIUP_INSTALL_DIR="$XDG_DATA_HOME/suiup"

### ─────────────────────────────────────────────────────────────
### Pnpm home
### ─────────────────────────────────────────────────────────────
export PNPM_HOME="/home/sliziard/.local/share/pnpm"

### ─────────────────────────────────────────────────────────────
### PATH 
### ─────────────────────────────────────────────────────────────
#?# 'path' is a special zsh variable, a table of string synched 
#?# on '$PATH'
typeset -U path PATH

path+=(
  "$HOME/.local/bin"
  "$HOME/.local/share/pnpm"
  "$HOME/.local/funcheck/host"
  "$SUIUP_INSTALL_DIR"
  "$CARGO_HOME/bin"
  "$HOME/.dotnet/tools"
)

export PATH

