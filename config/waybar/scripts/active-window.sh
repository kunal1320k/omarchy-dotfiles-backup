#!/usr/bin/env bash
# Waybar Active Window widget for Hyprland
# Shows focused window class + title, outputs Waybar JSON

MAX_LEN=35

truncate() {
  local str="$1"
  local max="$2"
  if [ "${#str}" -gt "$max" ]; then
    echo "${str:0:$max}…"
  else
    echo "$str"
  fi
}

escape_json() {
  # Escape special chars for JSON string
  echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

# Get active window info from hyprctl
WINFO=$(hyprctl activewindow -j 2>/dev/null)

if [ -z "$WINFO" ] || [ "$WINFO" = "{}" ]; then
  echo '{"text": "  Desktop", "tooltip": "No window focused", "class": "desktop"}'
  exit 0
fi

CLASS=$(echo "$WINFO" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('class',''))" 2>/dev/null)
TITLE=$(echo "$WINFO" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title',''))" 2>/dev/null)

if [ -z "$CLASS" ] && [ -z "$TITLE" ]; then
  echo '{"text": "  Desktop", "tooltip": "No window focused", "class": "desktop"}'
  exit 0
fi

# Pick icon based on window class
case "${CLASS,,}" in
  *alacritty*|*kitty*|*foot*|*ghostty*|*wezterm*|*terminal*)
    ICON="󰆍" ;;
  *firefox*|*chromium*|*brave*|*chrome*)
    ICON="󰈹" ;;
  *code*|*vscode*|*nvim*|*neovim*|*helix*|*vim*)
    ICON="󰨞" ;;
  *nautilus*|*thunar*|*nemo*|*pcmanfm*)
    ICON="󰉋" ;;
  *spotify*|*music*|*rhythmbox*)
    ICON="󰓇" ;;
  *telegram*|*discord*|*slack*|*signal*)
    ICON="󰭹" ;;
  *gimp*|*inkscape*|*krita*)
    ICON="󰏘" ;;
  *steam*|*lutris*|*heroic*)
    ICON="󰍎" ;;
  *obsidian*)
    ICON="󱓧" ;;
  *mpv*|*vlc*|*celluloid*)
    ICON="󰎁" ;;
  *)
    ICON="󰖯" ;;
esac

SHORT_TITLE=$(truncate "$TITLE" "$MAX_LEN")
SAFE_TITLE=$(escape_json "$SHORT_TITLE")
SAFE_FULL=$(escape_json "$TITLE")
SAFE_CLASS=$(escape_json "$CLASS")

echo "{\"text\": \"${ICON}  ${SAFE_TITLE}\", \"tooltip\": \"${SAFE_CLASS}: ${SAFE_FULL}\", \"class\": \"active-window\"}"
