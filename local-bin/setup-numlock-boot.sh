#!/usr/bin/env bash
set -e

echo "=== Setting up Num Lock on boot for Omarchy / Arch Linux ==="

# 1. SDDM display manager configuration
echo "[1/3] Configuring SDDM Num Lock..."
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/numlock.conf > /dev/null << 'EOF'
[General]
Numlock=on
EOF
echo "  -> /etc/sddm.conf.d/numlock.conf created."

# 2. Virtual Consoles (TTY) systemd service
echo "[2/3] Configuring Systemd Num Lock service for virtual consoles (TTYs)..."
sudo tee /etc/systemd/system/numlock.service > /dev/null << 'EOF'
[Unit]
Description=Enable NumLock on TTYs on boot
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for tty in /dev/tty[1-6]; do /usr/bin/setleds -D +num < "$tty" 2>/dev/null || true; done'

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable numlock.service
echo "  -> systemd numlock.service enabled."

# 3. Hyprland user configuration
echo "[3/3] Verifying Hyprland configuration..."
HYPR_INPUT="$HOME/.config/hypr/input.conf"
if [ -f "$HYPR_INPUT" ]; then
    if ! grep -q "numlock_by_default" "$HYPR_INPUT"; then
        echo "  numlock_by_default = true" >> "$HYPR_INPUT"
        echo "  -> Added numlock_by_default = true to $HYPR_INPUT"
    else
        echo "  -> Hyprland input configuration already contains numlock_by_default = true"
    fi
else
    mkdir -p "$HOME/.config/hypr"
    cat << 'EOF' > "$HYPR_INPUT"
input {
    numlock_by_default = true
}
EOF
    echo "  -> Created $HYPR_INPUT with numlock_by_default = true"
fi

echo "=== Num Lock configuration completed successfully! ==="
