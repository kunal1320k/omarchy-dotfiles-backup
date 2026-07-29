#!/usr/bin/env bash
# Waybar Now Playing widget using playerctl
# Returns JSON with text, tooltip, and class for styling

MAX_LEN=30

get_status() {
  playerctl status 2>/dev/null
}

truncate() {
  local str="$1"
  local max="$2"
  if [ "${#str}" -gt "$max" ]; then
    echo "${str:0:$max}…"
  else
    echo "$str"
  fi
}

STATUS=$(get_status)

if [ -z "$STATUS" ] || [ "$STATUS" = "No players found" ]; then
  echo '{"text": "", "tooltip": "", "class": "stopped", "alt": "stopped"}'
  exit 0
fi

PLAYER=$(playerctl -l 2>/dev/null | head -1)
TITLE=$(playerctl metadata title 2>/dev/null | sed 's/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g')
ARTIST=$(playerctl metadata artist 2>/dev/null | sed 's/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g')

if [ -z "$TITLE" ]; then
  echo '{"text": "", "tooltip": "", "class": "stopped", "alt": "stopped"}'
  exit 0
fi

# Choose icon based on status
if [ "$STATUS" = "Playing" ]; then
  ICON="󰎈"
  CLASS="playing"
else
  ICON="󰏤"
  CLASS="paused"
fi

# Build display text
if [ -n "$ARTIST" ]; then
  DISPLAY="${ARTIST} – ${TITLE}"
else
  DISPLAY="$TITLE"
fi

SHORT=$(truncate "$DISPLAY" "$MAX_LEN")

# Tooltip with full info
if [ -n "$ARTIST" ]; then
  TOOLTIP="${TITLE}\n${ARTIST}\n[${STATUS}]"
else
  TOOLTIP="${TITLE}\n[${STATUS}]"
fi

echo "{\"text\": \"${ICON}  ${SHORT}\", \"tooltip\": \"${TOOLTIP}\", \"class\": \"${CLASS}\", \"alt\": \"${CLASS}\"}"
