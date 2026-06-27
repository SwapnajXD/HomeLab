#!/bin/sh

OUTDIR="$HOME/homelab/data"
mkdir -p "$OUTDIR"

ID=$(awk -v min=1 -v max=1025 'BEGIN {
  srand()
  print int(min + rand() * (max - min + 1))
}')

POKEMON=$(curl -s "https://pokeapi.co/api/v2/pokemon/$ID")

NAME=$(echo "$POKEMON" | jq -r '.name')
SPRITE=$(echo "$POKEMON" | jq -r '.sprites.front_default')

TYPE1=$(echo "$POKEMON" | jq -r '.types[0].type.name')
TYPE2=$(echo "$POKEMON" | jq -r '.types[1].type.name // ""')

HEIGHT_RAW=$(echo "$POKEMON" | jq -r '.height')
WEIGHT_RAW=$(echo "$POKEMON" | jq -r '.weight')

HEIGHT=$(awk "BEGIN { printf \"%.1f\", $HEIGHT_RAW/10 }")
WEIGHT=$(awk "BEGIN { printf \"%.1f\", $WEIGHT_RAW/10 }")

ABILITIES=$(echo "$POKEMON" | jq '
[
  .abilities[].ability.name
]
')

cat > "$OUTDIR/pokemon.json" <<EOF
{
  "id": $ID,
  "name": "$NAME",
  "sprite": "$SPRITE",
  "type1": "$TYPE1",
  "type2": "$TYPE2",
  "height": "${HEIGHT} m",
  "weight": "${WEIGHT} kg",
  "abilities": $ABILITIES
}
EOF

echo "Generated Pokemon:"
cat "$OUTDIR/pokemon.json" | jq
