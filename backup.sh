#!/usr/bin/env bash
# ==============================================================================
# Omarchy / Hyprland / Wallpapers / Custom Scripts Automated Backup Script
# ==============================================================================
set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

echo "=========================================="
echo "Starting System Backup: $TIMESTAMP"
echo "Backup Directory: $BACKUP_DIR"
echo "=========================================="

# 1. Package Inventory
echo "[1/9] Exporting installed package lists..."
mkdir -p "$BACKUP_DIR/packages"
if command -v pacman &>/dev/null; then
    pacman -Qqe > "$BACKUP_DIR/packages/pacman-explicit.txt"
    pacman -Qqem > "$BACKUP_DIR/packages/aur-packages.txt"
    pacman -Qe > "$BACKUP_DIR/packages/full-system-packages.txt"
    echo "  - Pacman explicit & AUR package lists updated."
fi

if command -v flatpak &>/dev/null; then
    flatpak list --app --columns=application > "$BACKUP_DIR/packages/flatpak-packages.txt" 2>/dev/null || true
    echo "  - Flatpak package list updated."
fi

# 2. Config Files Snapshot
echo "[2/9] Backing up configuration files (~/.config)..."
mkdir -p "$BACKUP_DIR/config/hypr"
mkdir -p "$BACKUP_DIR/config/waybar"
mkdir -p "$BACKUP_DIR/config/omarchy"
mkdir -p "$BACKUP_DIR/config/mako"
mkdir -p "$BACKUP_DIR/config/walker"
mkdir -p "$BACKUP_DIR/config/terminals"
mkdir -p "$BACKUP_DIR/config/system-tools"

# Hyprland
rsync -a --delete ~/.config/hypr/ "$BACKUP_DIR/config/hypr/"
echo "  - Hyprland configs backed up."

# Waybar & Scripts
rsync -a --delete ~/.config/waybar/ "$BACKUP_DIR/config/waybar/"
echo "  - Waybar & custom scripts backed up."

# Omarchy Full Config (Hooks, Themes, Templates, Current Theme state)
if [ -d ~/.config/omarchy ]; then
    rsync -a --delete ~/.config/omarchy/ "$BACKUP_DIR/config/omarchy/"
fi
echo "  - Omarchy configs, hooks & themes backed up."

# SwayNC, Mako, Walker, GTK
if [ -d ~/.config/swaync ]; then mkdir -p "$BACKUP_DIR/config/swaync"; rsync -a --delete ~/.config/swaync/ "$BACKUP_DIR/config/swaync/"; fi
if [ -d ~/.config/mako ];   then rsync -a --delete ~/.config/mako/ "$BACKUP_DIR/config/mako/"; fi
if [ -d ~/.config/walker ]; then rsync -a --delete ~/.config/walker/ "$BACKUP_DIR/config/walker/"; fi
if [ -d ~/.config/gtk-3.0 ]; then mkdir -p "$BACKUP_DIR/config/gtk-3.0"; rsync -a --delete ~/.config/gtk-3.0/ "$BACKUP_DIR/config/gtk-3.0/"; fi
if [ -d ~/.config/gtk-4.0 ]; then mkdir -p "$BACKUP_DIR/config/gtk-4.0"; rsync -a --delete ~/.config/gtk-4.0/ "$BACKUP_DIR/config/gtk-4.0/"; fi

# Terminals
for term in alacritty foot kitty ghostty; do
    if [ -d ~/.config/$term ]; then
        mkdir -p "$BACKUP_DIR/config/terminals/$term"
        rsync -a --delete ~/.config/$term/ "$BACKUP_DIR/config/terminals/$term/"
    fi
done
echo "  - Terminal configs backed up."

# System Tools & Desktop Configs
for tool in btop fastfetch swayosd wlogout fuzzel uwsm quickshell cava wiremix nvtop; do
    if [ -d ~/.config/$tool ]; then
        mkdir -p "$BACKUP_DIR/config/system-tools/$tool"
        rsync -a --delete ~/.config/$tool/ "$BACKUP_DIR/config/system-tools/$tool/"
    fi
done
if [ -f ~/.config/starship.toml ]; then
    cp ~/.config/starship.toml "$BACKUP_DIR/config/system-tools/"
fi
if [ -f ~/.config/mimeapps.list ]; then
    cp ~/.config/mimeapps.list "$BACKUP_DIR/config/system-tools/"
fi
if [ -f ~/.config/xdg-terminals.list ]; then
    cp ~/.config/xdg-terminals.list "$BACKUP_DIR/config/system-tools/"
fi
if [ -f ~/.config/user-dirs.dirs ]; then
    cp ~/.config/user-dirs.dirs "$BACKUP_DIR/config/system-tools/"
fi
echo "  - System tool & desktop configs backed up."

# 3. ALL Wallpapers (Omarchy Backgrounds + Pictures Wallpapers)
echo "[3/9] Backing up ALL wallpapers..."
mkdir -p "$BACKUP_DIR/wallpapers/omarchy-backgrounds"
mkdir -p "$BACKUP_DIR/wallpapers/pictures"

if [ -d ~/.config/omarchy/backgrounds ]; then
    rsync -a --delete ~/.config/omarchy/backgrounds/ "$BACKUP_DIR/wallpapers/omarchy-backgrounds/"
    echo "  - All Omarchy theme backgrounds backed up."
fi

for img in ~/Pictures/*.jpg ~/Pictures/*.png ~/Pictures/*.jpeg ~/Pictures/*.webp; do
    if [ -f "$img" ]; then
        cp "$img" "$BACKUP_DIR/wallpapers/pictures/" 2>/dev/null || true
    fi
done
echo "  - User Pictures wallpaper files backed up."

# 4. Custom Local Binaries & Python/Shell Scripts (~/.local/bin)
echo "[4/9] Backing up custom scripts & binaries (~/.local/bin)..."
mkdir -p "$BACKUP_DIR/local-bin"
if [ -d ~/.local/bin ]; then
    rsync -a --delete ~/.local/bin/ "$BACKUP_DIR/local-bin/"
    chmod +x "$BACKUP_DIR/local-bin/"* 2>/dev/null || true
fi
echo "  - Custom scripts & binaries in ~/.local/bin backed up."

# 5. Custom Projects (PyBonsai)
echo "[5/9] Backing up custom projects..."
mkdir -p "$BACKUP_DIR/projects"
if [ -d ~/PyBonsai ]; then
    rsync -a --delete --exclude="__pycache__" --exclude=".git" ~/PyBonsai/ "$BACKUP_DIR/projects/PyBonsai/"
    echo "  - PyBonsai project backed up."
fi

# 6. Shell & Home Dotfiles
echo "[6/9] Backing up shell & home dotfiles..."
mkdir -p "$BACKUP_DIR/shell"
if [ -f ~/.bashrc ];      then cp ~/.bashrc      "$BACKUP_DIR/shell/"; fi
if [ -f ~/.bash_profile ]; then cp ~/.bash_profile "$BACKUP_DIR/shell/"; fi
if [ -f ~/.bash_logout ]; then cp ~/.bash_logout  "$BACKUP_DIR/shell/"; fi
if [ -f ~/.zshrc ];       then cp ~/.zshrc        "$BACKUP_DIR/shell/"; fi
if [ -f ~/.XCompose ];    then cp ~/.XCompose     "$BACKUP_DIR/shell/"; fi
echo "  - Shell configs (.bashrc, .bash_profile, .zshrc, .XCompose) backed up."

# 7. Git, Editor & Dev Tool Configs
echo "[7/9] Backing up git, editor & dev tool configs..."
mkdir -p "$BACKUP_DIR/config/dev-tools"

# Git config (~/.config/git/)
if [ -d ~/.config/git ]; then
    mkdir -p "$BACKUP_DIR/config/dev-tools/git"
    rsync -a --delete ~/.config/git/ "$BACKUP_DIR/config/dev-tools/git/"
    echo "  - Git config backed up."
fi

# Neovim
if [ -d ~/.config/nvim ]; then
    mkdir -p "$BACKUP_DIR/config/dev-tools/nvim"
    rsync -a --delete --exclude=".git" --exclude="lazy-lock.json" ~/.config/nvim/ "$BACKUP_DIR/config/dev-tools/nvim/"
    echo "  - Neovim config backed up."
fi

# LazyGit
if [ -d ~/.config/lazygit ]; then
    mkdir -p "$BACKUP_DIR/config/dev-tools/lazygit"
    rsync -a --delete ~/.config/lazygit/ "$BACKUP_DIR/config/dev-tools/lazygit/"
    echo "  - LazyGit config backed up."
fi

# Zed editor
if [ -d ~/.config/zed ]; then
    mkdir -p "$BACKUP_DIR/config/dev-tools/zed"
    rsync -a --delete ~/.config/zed/ "$BACKUP_DIR/config/dev-tools/zed/"
    echo "  - Zed editor config backed up."
fi

# Micro editor
if [ -d ~/.config/micro ]; then
    mkdir -p "$BACKUP_DIR/config/dev-tools/micro"
    rsync -a --delete ~/.config/micro/ "$BACKUP_DIR/config/dev-tools/micro/"
    echo "  - Micro editor config backed up."
fi

# Tmux
if [ -d ~/.config/tmux ]; then
    mkdir -p "$BACKUP_DIR/config/dev-tools/tmux"
    rsync -a --delete ~/.config/tmux/ "$BACKUP_DIR/config/dev-tools/tmux/"
    echo "  - Tmux config backed up."
fi

# Fish shell
if [ -d ~/.config/fish ]; then
    mkdir -p "$BACKUP_DIR/config/dev-tools/fish"
    rsync -a --delete ~/.config/fish/ "$BACKUP_DIR/config/dev-tools/fish/"
    echo "  - Fish shell config backed up."
fi

# OpenCode / AI Dev tools
if [ -d ~/.config/opencode ]; then
    mkdir -p "$BACKUP_DIR/config/dev-tools/opencode"
    rsync -a --delete ~/.config/opencode/ "$BACKUP_DIR/config/dev-tools/opencode/"
    echo "  - OpenCode config backed up."
fi

echo "  - Dev tool configs backed up."

# 8. App Configs (Spicetify, Obsidian, fonts, etc.)
echo "[8/9] Backing up app & font configs..."
mkdir -p "$BACKUP_DIR/config/apps"

# Spicetify (Spotify customization)
if [ -d ~/.config/spicetify ]; then
    mkdir -p "$BACKUP_DIR/config/apps/spicetify"
    rsync -a --delete --exclude="Extracted" ~/.config/spicetify/ "$BACKUP_DIR/config/apps/spicetify/"
    echo "  - Spicetify config backed up."
fi

# Obsidian (app settings only, not vault data)
if [ -d ~/.config/obsidian ]; then
    mkdir -p "$BACKUP_DIR/config/apps/obsidian"
    rsync -a --delete ~/.config/obsidian/ "$BACKUP_DIR/config/apps/obsidian/"
    echo "  - Obsidian config backed up."
fi

# Matugen (color generation)
if [ -d ~/.config/matugen ]; then
    mkdir -p "$BACKUP_DIR/config/apps/matugen"
    rsync -a --delete ~/.config/matugen/ "$BACKUP_DIR/config/apps/matugen/"
    echo "  - Matugen config backed up."
fi

# Fontconfig
if [ -d ~/.config/fontconfig ]; then
    mkdir -p "$BACKUP_DIR/config/apps/fontconfig"
    rsync -a --delete ~/.config/fontconfig/ "$BACKUP_DIR/config/apps/fontconfig/"
    echo "  - Fontconfig backed up."
fi

# Custom omarchy font (if present in config root)
if [ -f ~/.config/omarchy.ttf ]; then
    cp ~/.config/omarchy.ttf "$BACKUP_DIR/config/apps/"
    echo "  - Omarchy font backed up."
fi

echo "  - App & font configs backed up."

# 9. GPG Keys (encrypted key export)
echo "[9/9] Backing up GPG keys..."
mkdir -p "$BACKUP_DIR/gnupg"
if command -v gpg &>/dev/null && gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q "sec"; then
    gpg --export-secret-keys --armor > "$BACKUP_DIR/gnupg/secret-keys.asc" 2>/dev/null || true
    gpg --export --armor > "$BACKUP_DIR/gnupg/public-keys.asc" 2>/dev/null || true
    gpg --export-ownertrust > "$BACKUP_DIR/gnupg/ownertrust.txt" 2>/dev/null || true
    echo "  - GPG keys exported."
else
    echo "  - No GPG secret keys found, skipping."
fi

echo "=========================================="
echo "Backup Completed Successfully at $(date '+%H:%M:%S')!"
echo "=========================================="
