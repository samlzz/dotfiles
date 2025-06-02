# Replace ls with exa
alias ls='exa --color=always --group-directories-first --icons'
alias la='exa -a --color=always --group-directories-first --icons'   # all files and dirs
alias ll='exa -l --color=always --group-directories-first --icons'   # long format
alias lt='exa -T --color=always --group-directories-first --icons'   # tree listing
alias lta='exa -aT --color=always --group-directories-first --icons' # tree listing of all files and dirs

alias cl="clear"

alias vl="valgrind"
alias vla="valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all --track-fds=yes"

alias ccw="gcc -Wall -Wextra -Werror"

alias mk="make"
alias py="python3"
alias cm="chezmoi"

alias sz="source $HOME/.zshrc"

if command -v "rm_secure" &>/dev/null; then
	alias rm="rm_secure"
fi

source "$XDG_STATE_HOME/ctools/git.zsh"
