#!/usr/bin/env bash
# ==============================================================================
# Omarchy / Hyprland / Wallpapers / Custom Scripts Restoration Script
# ==============================================================================
set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Omarchy Desktop & Dotfiles Restoration"
echo "Backup Directory: $BACKUP_DIR"
echo "=========================================="

read -p "Do you want to restore configuration files, custom scripts, and all wallpapers? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "[1/5] Restoring configuration files to ~/.config..."
    mkdir -p ~/.config

    # Hyprland
    if [ -d "$BACKUP_DIR/config/hypr" ]; then
        mkdir -p ~/.config/hypr
        rsync -a "$BACKUP_DIR/config/hypr/" ~/.config/hypr/
        echo "  - Hyprland configs restored."
    fi

    # Waybar & scripts
    if [ -d "$BACKUP_DIR/config/waybar" ]; then
        mkdir -p ~/.config/waybar
        rsync -a "$BACKUP_DIR/config/waybar/" ~/.config/waybar/
        chmod +x ~/.config/waybar/scripts/*.sh 2>/dev/null || true
        echo "  - Waybar & custom scripts restored."
    fi

    # Omarchy theme assets & hooks
    if [ -d "$BACKUP_DIR/config/omarchy" ]; then
        mkdir -p ~/.config/omarchy/hooks
        mkdir -p ~/.config/omarchy/extensions
        rsync -a "$BACKUP_DIR/config/omarchy/" ~/.config/omarchy/
        chmod +x ~/.config/omarchy/hooks/* 2>/dev/null || true
        chmod +x ~/.config/omarchy/extensions/* 2>/dev/null || true
        echo "  - Omarchy hooks restored."
    fi

    # Mako & Walker
    if [ -d "$BACKUP_DIR/config/mako" ]; then rsync -a "$BACKUP_DIR/config/mako/" ~/.config/mako/; fi
    if [ -d "$BACKUP_DIR/config/walker" ]; then rsync -a "$BACKUP_DIR/config/walker/" ~/.config/walker/; fi

    # Terminals
    if [ -d "$BACKUP_DIR/config/terminals" ]; then
        for term in alacritty foot kitty ghostty; do
            if [ -d "$BACKUP_DIR/config/terminals/$term" ]; then
                mkdir -p ~/.config/$term
                rsync -a "$BACKUP_DIR/config/terminals/$term/" ~/.config/$term/
            fi
        done
        echo "  - Terminal configs restored."
    fi

    # System Tools & Desktop Configs
    if [ -d "$BACKUP_DIR/config/system-tools" ]; then
        for tool in btop fastfetch swayosd wlogout fuzzel uwsm quickshell cava; do
            if [ -d "$BACKUP_DIR/config/system-tools/$tool" ]; then
                mkdir -p ~/.config/$tool
                rsync -a "$BACKUP_DIR/config/system-tools/$tool/" ~/.config/$tool/
            fi
        done
        if [ -f "$BACKUP_DIR/config/system-tools/starship.toml" ]; then
            cp "$BACKUP_DIR/config/system-tools/starship.toml" ~/.config/
        fi
        if [ -f "$BACKUP_DIR/config/system-tools/mimeapps.list" ]; then
            cp "$BACKUP_DIR/config/system-tools/mimeapps.list" ~/.config/
        fi
        echo "  - System tool & desktop configs restored."
    fi

    # 2. ALL Wallpapers
    echo "[2/5] Restoring ALL wallpapers..."
    if [ -d "$BACKUP_DIR/wallpapers/omarchy-backgrounds" ]; then
        mkdir -p ~/.config/omarchy/backgrounds
        rsync -a "$BACKUP_DIR/wallpapers/omarchy-backgrounds/" ~/.config/omarchy/backgrounds/
        echo "  - All Omarchy theme backgrounds restored."
    fi
    if [ -d "$BACKUP_DIR/wallpapers/pictures" ]; then
        mkdir -p ~/Pictures
        cp "$BACKUP_DIR/wallpapers/pictures/"* ~/Pictures/ 2>/dev/null || true
        echo "  - User Pictures wallpapers restored."
    fi

    # 3. Local Binaries & Custom Python/Shell Scripts
    echo "[3/5] Restoring custom binaries and Python/Shell scripts to ~/.local/bin..."
    mkdir -p ~/.local/bin
    if [ -d "$BACKUP_DIR/local-bin" ]; then
        cp "$BACKUP_DIR/local-bin/"* ~/.local/bin/ 2>/dev/null || true
        chmod +x ~/.local/bin/* 2>/dev/null || true
        echo "  - Custom binaries (omarchy-notification-center, setup-numlock-boot.sh, etc.) restored."
    fi

    # 4. Custom Projects
    echo "[4/5] Restoring custom projects..."
    if [ -d "$BACKUP_DIR/projects/PyBonsai" ]; then
        mkdir -p ~/PyBonsai
        rsync -a "$BACKUP_DIR/projects/PyBonsai/" ~/PyBonsai/
        chmod +x ~/PyBonsai/*.sh 2>/dev/null || true
        echo "  - PyBonsai project restored."
    fi

    # 5. Shell Dotfiles
    echo "[5/5] Restoring shell dotfiles..."
    if [ -f "$BACKUP_DIR/shell/.bashrc" ]; then cp "$BACKUP_DIR/shell/.bashrc" ~/.bashrc; fi
    if [ -f "$BACKUP_DIR/shell/.zshrc" ]; then cp "$BACKUP_DIR/shell/.zshrc" ~/.zshrc; fi
    echo "  - Shell configs restored."

    echo "------------------------------------------"
    echo "Reloading Desktop Components..."
    if command -v omarchy &>/dev/null; then
        omarchy theme set Vantablack 2>/dev/null || true
        omarchy restart waybar 2>/dev/null || true
    fi
    if command -v hyprctl &>/dev/null; then
        hyprctl reload 2>/dev/null || true
    fi
    echo "Restoration finished successfully!"
else
    echo "Restoration cancelled."
fi
