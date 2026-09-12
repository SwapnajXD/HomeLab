#!/bin/sh

API_KEY="0d7e22413d326630a68502a528df7730"
USERNAME="Swapnaj"

OUTDIR="$HOME/homelab/data"
mkdir -p "$OUTDIR"

TMP="/tmp/lastfm_raw.json"

curl -s \
"https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=${USERNAME}&api_key=${API_KEY}&format=json&limit=1" \
> "$TMP"

# If invalid JSON → fallback
if ! jq empty "$TMP" >/dev/null 2>&1; then
  jq -n '{
    track:"N/A",
    artist:"N/A",
    album:"N/A",
    cover:"",
    nowplaying:false,
    played_at:"",
    elapsed:"Unknown",
    status:"Unavailable"
  }' > "$OUTDIR/lastfm.json"
  exit 0
fi

TRACK=$(jq -r '.recenttracks.track[0].name // "N/A"' "$TMP")
ARTIST=$(jq -r '.recenttracks.track[0].artist["#text"] // "N/A"' "$TMP")
ALBUM=$(jq -r '.recenttracks.track[0].album["#text"] // "N/A"' "$TMP")
COVER=$(jq -r '.recenttracks.track[0].image[-1]["#text"] // ""' "$TMP")

NOWPLAYING=$(jq -r '.recenttracks.track[0]["@attr"].nowplaying // "false"' "$TMP")
PLAYED_AT=$(jq -r '.recenttracks.track[0].date.uts // ""' "$TMP")

if [ "$NOWPLAYING" = "true" ]; then
  STATUS="Now Playing"
  ELAPSED="Playing"
else
  STATUS="Last Played"

  if [ -n "$PLAYED_AT" ]; then
    NOW=$(date +%s)
    DIFF=$((NOW - PLAYED_AT))

    DAYS=$((DIFF / 86400))
    HOURS=$(((DIFF % 86400) / 3600))
    MINS=$(((DIFF % 3600) / 60))

    if [ "$DAYS" -gt 0 ]; then
      ELAPSED="${DAYS}d ${HOURS}h ago"
    elif [ "$HOURS" -gt 0 ]; then
      ELAPSED="${HOURS}h ${MINS}m ago"
    else
      ELAPSED="${MINS}m ago"
    fi
  else
    ELAPSED="Unknown"
  fi
fi

jq -n \
  --arg track "$TRACK" \
  --arg artist "$ARTIST" \
  --arg album "$ALBUM" \
  --arg cover "$COVER" \
  --arg nowplaying "$NOWPLAYING" \
  --arg played_at "$PLAYED_AT" \
  --arg elapsed "$ELAPSED" \
  --arg status "$STATUS" \
'{
  track:$track,
  artist:$artist,
  album:$album,
  cover:$cover,
  nowplaying:($nowplaying=="true"),
  played_at:$played_at,
  elapsed:$elapsed,
  status:$status
}' > "$OUTDIR/lastfm.json"
