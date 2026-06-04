# Replace ls with exa

if command -v 'eza' &> /dev/null; then
	alias ls='eza --group-directories-first'
	alias la='eza -a --group-directories-first'   # all files and dirs
	alias ll='eza -l --group-directories-first'   # long format
	alias lt='eza -T --group-directories-first'   # tree listing
	alias lta='eza -aT --group-directories-first --git-ignore' # tree listing of all files and dirs
else
	alias la='ls --all'     # all files and dirs
	alias ll='ls -l'        # long format

	if command -v 'tree' &> /dev/null; then
		alias lt='tree'     # tree listing
		alias lta='tree -a' # tree listing of all files and dirs
	fi
fi
alias cl='clear'

if command -v 'valgrind' &> /dev/null; then
	alias vl='valgrind'
	alias vla='valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all --track-fds=yes'
fi

alias ccw='gcc -Wall -Wextra -Werror'

alias mk='make'
alias py='python3'
alias dots='~/dotfiles/'
alias gdots="git -C ~/dotfiles/"

alias e="$EDITOR"

alias sz="source $HOME/.zshenv && source $XDG_CONFIG_HOME/zsh/.zshrc"

if command -v 'rm_secure' &>/dev/null; then
	alias rm='rm_secure'
fi

if command -v 'uxplay' &> /dev/null; then
	alias airplay='uxplay -p 7000 -s 1920x1080 -vs waylandsink -as pipewiresink'
fi