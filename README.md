# samlzz-dotfiles

This repository contains my personal dotfiles, configuration, and setup automation scripts, managed using [`chezmoi`](https://www.chezmoi.io/) to ensure portability and reproducibility across systems.

> **Target environment:** Arch Linux (Hyprland), zsh, VS Code, tmux, Wayland.  
> **Laptop:** Framework 13 (13ᵉ gen Intel, i915 GPU).  
> **DE:** Hyprland (Wayland) + GNOME fallback.

---

## 📦 Features

- 🧠 **Declarative config** with `chezmoi` for reproducible setups
- 🎨 **Catppuccin Mocha** themed across `alacritty`, `rofi`, `waybar`, `tmux`, `zsh`
- ⚡️ **Hyprland integration**: idle/lock/suspend flow, animations, plugins via `hyprpm`
- 🖥 **tmux** with resurrect/continuum
- ⚙️ **CLI tools**: custom scripts for wallpaper, DNS, secure deletion, and git
- 🧰 **VS Code config**: tailored settings per language (`ts`, `c`, `py`, etc.)
- 🌐 **Systemd units** for `hypridle`, idle logic, and user services
- 🔄 **Bootstrap scripts** for system setup, Oh-My-Zsh, plugins, and more

---

## 📁 Structure Overview

```text
samlzz-dotfiles/
├── chezmoi_config                    # chezmoi diff customization (uses delta)
├── code_settings.json               # VS Code user settings (tmpl linked)
├── dot_*                             # Generic dotfiles: .zshrc, .vimrc, .gitconfig…
├── dot_config/                      # XDG_CONFIG_HOME subtree
│   ├── hypr/                        # Hyprland config: idle, lock, paper, plugins
│   ├── alacritty/                  # Terminal theme + settings
│   ├── rofi/                       # UI launcher with Catppuccin styles
│   ├── waybar/                     # Waybar modules, scripts, and styling
│   ├── systemd/                    # Custom user services (idle etc.)
│   └── tmux/                       # Tmux configuration
├── dot_local/
│   ├── bin/                        # CLI scripts (e.g. `ftinit`, `rm_secure`)
│   └── share/                      # XDG_STATE_HONE: Shell extensions, completions, omz themes, ...
├── packages/                       # Lists of packages: pacman, AUR, snap
├── run_once_*.sh                   # chezmoi init scripts: bootstrap, zsh, system services
└── Pictures/wallpapers/           # Wallpapers for Hyprland (used by hyprpaper)
```

---

## 🚀 Setup Guide

1. **Install dependencies**

   Use and `packages/install.sh`

2. **Setup ssh keys**

   - Create `~/.ssh` folder
   - Add keys in it with the `config` file

3. **Install chezmoi** and initialize:

   ```bash
   chezmoi init https://github.com/<your-username>/samlzz-dotfiles
   chezmoi apply
   ```

---

## ⚙️ Key Scripts

- `powerctl`: clean shutdown, suspend-then-hibernate, safe poweroff
- `rm_secure`: moves files to trash with timed emptying
- `wallpaperctl`: wallpaper management via hyprpaper
- `gitingest`, `gupdate`: Git-related workflow helpers
- `ftinit`, `hcreate`: project setup / hooks

---

## 📌 Notes

- Uses the **XDG Base Directory Spec** strictly
- Some files are `readonly` or `template` (`.tmpl`) controlled via chezmoi
- VS Code settings are supported and templated
- Most scripts are safely re-runnable (idempotent)

---

## 🧪 Tested On

- **Arch Linux (rolling)**
- Wayland (`Hyprland`, `swayidle`, `waybar`)
- VS Code + extensions
- Oh-My-Zsh + Powerlevel10k

---

## 📝 License

Personal configuration — use freely with credit, but review before applying blindly.
