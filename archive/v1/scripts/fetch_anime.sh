#!/bin/bash

USERNAME="StarLordXD"

OUTFILE="$HOME/homelab/data/anime.json"

URL="https://api.jikan.moe/v4/users/${USERNAME}/full"

DATA=$(curl -s "$URL")

WATCHING=$(echo "$DATA" | jq '.data.statistics.anime.watching // 0')
COMPLETED=$(echo "$DATA" | jq '.data.statistics.anime.completed // 0')
SCORE=$(echo "$DATA" | jq '.data.statistics.anime.mean_score // 0')

jq -n \
  --arg user "$USERNAME" \
  --argjson watching "$WATCHING" \
  --argjson completed "$COMPLETED" \
  --argjson score "$SCORE" \
'{
  username: $user,
  watching: $watching,
  completed: $completed,
  score: $score
}' > "$OUTFILE"
