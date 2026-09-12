#!/bin/bash

OWNER="SwapnajXD"
REPO="Walls"

MEDIA_FILE="/home/ubuntu/homelab/data/media.json"
LASTFM_FILE="/home/ubuntu/homelab/data/lastfm.json"

# -------------------------
# LASTFM MODE
# -------------------------
if [ -f "$LASTFM_FILE" ]; then

  NOWPLAYING=$(jq -r '.nowplaying // false' "$LASTFM_FILE")
  COVER=$(jq -r '.cover // ""' "$LASTFM_FILE")

  if [ "$NOWPLAYING" = "true" ] && [ -n "$COVER" ] && [ "$COVER" != "null" ]; then

    TRACK=$(jq -r '.track // "Unknown Track"' "$LASTFM_FILE")
    ARTIST=$(jq -r '.artist // "Unknown Artist"' "$LASTFM_FILE")

    jq -n \
      --arg mode "album" \
      --arg title "$TRACK" \
      --arg subtitle "$ARTIST" \
      --arg url "$COVER" \
      '{
        mode:$mode,
        title:$title,
        subtitle:$subtitle,
        url:$url
      }' > "$MEDIA_FILE"

    exit 0
  fi
fi

# -------------------------
# WALLPAPER FALLBACK (SIMPLE + SAFE)
# -------------------------

URL="https://api.github.com/repos/${OWNER}/${REPO}/contents"

RAW=$(curl -s "$URL")

WALLPAPER=$(echo "$RAW" | jq -r '
try (.[] | select(.name? and (.name | test("\\.(jpg|jpeg|png|webp|gif)$"; "i"))) | .name) catch empty
' | shuf -n 1)

# fallback if empty
if [ -z "$WALLPAPER" ]; then
  WALLPAPER="default.jpg"
fi

TITLE=$(echo "$WALLPAPER" | sed 's/\.[^.]*$//' | sed 's/[-_]/ /g')

RAW_URL="https://raw.githubusercontent.com/${OWNER}/${REPO}/master/${WALLPAPER}"

jq -n \
  --arg mode "wallpaper" \
  --arg title "$TITLE" \
  --arg url "$RAW_URL" \
'{
  mode:$mode,
  title:$title,
  url:$url
}' > "$MEDIA_FILE"
