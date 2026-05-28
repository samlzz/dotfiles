# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).  
**Arch Linux · Hyprland · Zsh · Neovim · Catppuccin Mocha**

---

## Structure

Stow packages live under `packages/`. Each one mirrors the home directory tree so Stow can symlink files directly into `~`.

```
dotfiles/
├── packages/
│   ├── mysh/        # Zsh config, personal scripts (.local/bin) & completions
│   ├── prompt/      # Oh My Posh themes
│   ├── git/         # Git config + GitHub CLI (placeholder)
│   ├── editor/      # Neovim, Vim, VS Code settings
│   ├── terminal/    # Alacritty + Tmux
│   ├── hyprland/    # Hyprland WM, hypridle, hyprlock, hyprpaper + scripts
│   ├── desktop/     # Waybar, swaync, swayosd, fuzzel, GTK themes
│   ├── themes/      # Shared CSS color variables (Catppuccin Mocha)
│   ├── tools/       # bat, lf, cava, glow, jrnl, oxker…
│   ├── ssh/         # SSH client config (keys excluded)
│   └── system/      # Systemd user units, Nerd fonts, XDG base settings
├── out_home/        # Files targeting / instead of ~ (requires sudo)
├── scripts/         # Utility scripts
├── templates/       # Reusable file templates (Makefile, .gitignore…)
└── Makefile
```

---

## Makefile

All Stow operations are driven from the repo root.

```bash
make                          # show help
make list                     # list available packages

make stow    PKG=mysh         # stow a single package
make stow    PKG="mysh git"   # stow multiple packages
make stow-all                 # stow every package

make unstow  PKG=terminal     # remove symlinks for a package
make restow  PKG=mysh         # re-symlink after adding files to a package

make dry-run PKG=desktop      # simulate without applying
make dry-run-all              # simulate everything
```

---

## Migration helper

`scripts/dotfiles-transition.sh` assists moving existing config into a Stow package.  
For each file in the given package it finds its system counterpart, shows a `delta` diff, and lets you resolve the conflict interactively.

```
[d] Delete system file       keep dotfiles version
[o] Overwrite dotfiles       pull in system version
[e] Edit source in $EDITOR   re-diff after saving
[s] Skip
```

A temporary backup is created before every destructive action — **Ctrl-C restores all modified files automatically**.

```bash
./scripts/dotfiles-transition.sh packages/mysh
```

---

## Sensitive files

Credentials and private keys are tracked in `.gitignore` and never committed:

| Path | Reason |
|------|--------|
| `ssh/.ssh/id_*` | SSH private keys |
| `git/.config/gh/` | GitHub CLI tokens |
| `rclone/.config/rclone/rclone.conf` | rclone credentials |

---

## System-level files

`out_home/` targets `/` instead of `~`. Apply it separately with elevated privileges:

```bash
sudo stow --dir="$PWD" --target=/ out_home
```

Or just mannualy:

```bash
cp ./out_home/usr/local/bin/* /usr/local/bin
```