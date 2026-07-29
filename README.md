# Omarchy & Hyprland Custom System Backup Repository

This repository contains a full backup of all desktop configurations, Vantablack theme wallpapers & hooks, custom Python and Shell scripts, dotfiles, and software package inventories for Omarchy Arch Linux with Hyprland.

---

## 📂 Backup Repository Structure

```
omarchy-dotfiles-backup/
├── backup.sh                      # Executable script to refresh backup snapshots
├── restore.sh                     # Executable script to restore setup on any machine
├── README.md                      # Detailed usage documentation
├── packages/
│   ├── pacman-explicit.txt        # Explicitly installed native Arch packages
│   ├── aur-packages.txt           # Installed AUR packages
│   ├── flatpak-packages.txt       # Installed Flatpak applications
│   └── full-system-packages.txt   # Complete package list with precise versions
├── config/
│   ├── hypr/                      # Hyprland WM configuration & rules
│   ├── waybar/                    # Waybar status bar layout, styles & custom scripts
│   ├── omarchy/                   # Vantablack theme wallpapers (makima.jpg, etc.) & hooks
│   ├── mako/                      # Mako notification daemon configs
│   ├── walker/                    # Walker application launcher settings
│   ├── terminals/                 # alacritty, foot, kitty, ghostty terminal configs
│   └── system-tools/              # btop, fastfetch, starship, swayosd, wlogout, fuzzel
├── local-bin/                     # Custom user binaries & scripts:
│   ├── omarchy-notification-center        (Python GTK Notification Center GUI)
│   ├── omarchy-notification-center-launch (Shell launcher)
│   ├── setup-numlock-boot.sh              (Numlock configuration script)
│   └── ghui                               (Shell GUI launcher)
├── projects/
│   └── PyBonsai/                  # PyBonsai Python CLI package & installer
└── shell/                         # Shell configuration files (.bashrc, .zshrc)
```

---

## 🚀 Usage Instructions

### 1. Updating the Backup (Routine Backup)

To refresh your backup with your latest system changes:

```bash
cd ~/omarchy-dotfiles-backup
./backup.sh
```

### 2. Backing Up to Git / GitHub / GitLab

To save your backup in a private Git repository:

```bash
cd ~/omarchy-dotfiles-backup
git init
git add .
git commit -m "Backup: Omarchy Vantablack desktop & custom scripts"
git remote add origin git@github.com:YOUR_USERNAME/omarchy-dotfiles-backup.git
git branch -M main
git push -u origin main
```

### 3. Restoring on a Fresh System

To restore your complete environment on a new machine or fresh Omarchy installation:

1. Clone or copy this repository to your target system.
2. Make scripts executable:
   ```bash
   chmod +x backup.sh restore.sh
   ```
3. Re-install your software packages:
   ```bash
   # Native packages
   sudo pacman -S --needed - < packages/pacman-explicit.txt

   # AUR packages
   yay -S --needed - < packages/aur-packages.txt
   ```
4. Run the restore script:
   ```bash
   ./restore.sh
   ```
