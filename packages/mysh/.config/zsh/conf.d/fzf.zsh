### ─────────────────────────────────────────────────────────────
### Fzf Catppuccin Mocha theme
### ─────────────────────────────────────────────────────────────

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

### ─────────────────────────────────────────────────────────────
### Fzf-tab
### ─────────────────────────────────────────────────────────────

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
    'eza -A --git -1 --follow-symlinks -l --no-filesize --no-permissions --no-user --no-time --color=always --icons=always $realpath'

# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
    '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

# systemd units status
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# git previews
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
	'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
	'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
	'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
	'case "$group" in
	"commit tag") git show --color=always $word ;;
	*) git show --color=always $word | delta ;;
	esac'
	zstyle ':fzf-tab:complete:g(it-checkout|hist):*' fzf-preview \
	'case "$group" in
	"modified file") git diff $word | delta ;;
	"recent commit object name") git show --color=always $word | delta ;;
	*) git log --color=always $word ;;
	esac'

# options: show --help of the current command
zstyle ':fzf-tab:complete:*:options' fzf-preview \
    '$words[1] --help 2>&1 | bat -plhelp --color=always'
zstyle ':fzf-tab:complete:*:options' fzf-flags --preview-window=down:6:wrap

# catch-all: file preview
export LESSOPEN="|$XDG_CONFIG_HOME/less/lessfilter %s"
zstyle ':fzf-tab:*' fzf-flags '--height=100%'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less -R ${(Q)realpath}'
zstyle ':fzf-tab:complete:*:*' fzf-flags --preview-window=right:'50%':wrap

# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

eval "$(fzf --zsh)"

