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
echo "[1/6] Exporting installed package lists..."
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
echo "[2/6] Backing up configuration files (~/.config)..."
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
if [ -d ~/.config/swaync ]; then rsync -a --delete ~/.config/swaync/ "$BACKUP_DIR/config/swaync/"; fi
if [ -d ~/.config/mako ]; then rsync -a --delete ~/.config/mako/ "$BACKUP_DIR/config/mako/"; fi
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
for tool in btop fastfetch swayosd wlogout fuzzel uwsm quickshell cava; do
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
echo "  - System tool & desktop configs backed up."

# 3. ALL Wallpapers (Omarchy Backgrounds + Pictures Wallpapers)
echo "[3/6] Backing up ALL wallpapers..."
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
echo "[4/6] Backing up custom scripts & binaries (~/.local/bin)..."
mkdir -p "$BACKUP_DIR/local-bin"
if [ -d ~/.local/bin ]; then
    rsync -a --delete ~/.local/bin/ "$BACKUP_DIR/local-bin/"
    chmod +x "$BACKUP_DIR/local-bin/"* 2>/dev/null || true
fi
echo "  - Custom scripts & binaries in ~/.local/bin backed up."

# 5. Custom Projects (PyBonsai)
echo "[5/6] Backing up custom projects..."
mkdir -p "$BACKUP_DIR/projects"
if [ -d ~/PyBonsai ]; then
    rsync -a --delete --exclude="__pycache__" --exclude=".git" ~/PyBonsai/ "$BACKUP_DIR/projects/PyBonsai/"
    echo "  - PyBonsai project backed up."
fi

# 6. Shell Dotfiles
echo "[6/6] Backing up shell dotfiles..."
mkdir -p "$BACKUP_DIR/shell"
if [ -f ~/.bashrc ]; then cp ~/.bashrc "$BACKUP_DIR/shell/"; fi
if [ -f ~/.zshrc ]; then cp ~/.zshrc "$BACKUP_DIR/shell/"; fi
echo "  - Shell configs (.bashrc, .zshrc) backed up."

echo "=========================================="
echo "Backup Completed Successfully at $(date '+%H:%M:%S')!"
echo "=========================================="
