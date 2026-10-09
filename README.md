# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).  
**Arch Linux · Hyprland · Zsh · Neovim · Catppuccin Mocha**

---

## Three tiers

Not every machine gets the full config:
| Tier | Where | What |
|------|-------|------|
| **Full** | Own Arch/Hyprland machines | Every package under `packages/` |
| **Workstation** | A laptop you own but go light on (work/school laptop) | `make stow-workstation` - see [Makefile](#makefile) |
| **Minimal / remote** | SSH into boxes you don't fully control | One self-contained script, no git/Stow on the remote end - see [Minimal / remote](#minimal--remote) |

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
├── remote/          # Minimal tier source files + the generated installer
│   ├── profile      # Env vars (EDITOR, LESS, PAGER, MANPAGER…), chains into bashrc
│   ├── bashrc       # Prompt, history, keybindings, aliases - bash only
│   ├── tmux.conf    # Plugin-free tmux config, opt-in at install time
│   ├── vimrc        # Sane vim defaults, no colorscheme
│   ├── less/        # Archives preview filter for less
│   └── install.sh   # Generated - see scripts/build-remote-bundle.sh
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

make stow-workstation         # stow the workstation tier (mysh prompt git editor terminal themes tools)
make unstow-workstation       # unstow it
make dry-run-workstation      # simulate it without applying
```

---

## Minimal / remote

For SSH sessions into boxes you don't control: no package installs,
bash only, no git clone or Stow needed on the remote end - just one file.

Source files live under `remote/`; `remote/install.sh` is the generated,
self-contained installer built from them (base64-embedded, plain POSIX
`sh`).
Regenerate it after editing any `remote/*` source file - never hand-edit `install.sh`:
```bash
./scripts/build-remote-bundle.sh   # regenerates remote/install.sh
```

Deploy it to a remote box and run it there - either copy it over:

```bash
scp remote/install.sh host:~/ && ssh host 'bash install.sh'
```

or curl it directly from the raw GitHub URL (no scp needed, as long as the remote box has outbound internet access):

```bash
curl -fsSL https://raw.githubusercontent.com/samlzz/dotfiles/refs/heads/main/remote/install.sh | bash
```

- Installs `~/.profile`, `~/.bashrc`, `~/.vimrc`, `~/.config/less/lessfilter`.
- Backs up any pre-existing target file first (timestamped, never silently clobbered).
- tmux is opt-in (not installed by default): `--with-tmux` / `--no-tmux`, or `WITH_TMUX=1`; prompts interactively if neither is given. Its prefix is **Ctrl+N**, not Ctrl+B, so it doesn't fight an outer/local tmux when you SSH from inside one.

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
