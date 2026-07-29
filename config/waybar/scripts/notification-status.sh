#!/bin/bash
# omarchy-notification-status - Waybar custom module for notification bell
# Outputs JSON for waybar with bell icon and notification history count

COUNT=$(makoctl history 2>/dev/null | grep -c '^Notification ' || echo "0")

if [ "$COUNT" -gt 0 ]; then
    echo "{\"text\": \"󰂚\", \"tooltip\": \"$COUNT notification(s) — click to view\", \"class\": \"has-notifications\", \"alt\": \"$COUNT\"}"
else
    echo "{\"text\": \"󰂜\", \"tooltip\": \"No notifications\", \"class\": \"\", \"alt\": \"0\"}"
fi
