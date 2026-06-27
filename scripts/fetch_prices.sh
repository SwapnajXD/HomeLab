#!/bin/sh

OUTDIR="$HOME/homelab/data"

fetch_price() {
  curl -sL \
    -A "Mozilla/5.0" \
    "https://query1.finance.yahoo.com/v8/finance/chart/$1" |
    jq '.chart.result[0].meta.regularMarketPrice'
}

GOLD=$(fetch_price "GOLDBEES.NS")
LIQUID=$(fetch_price "LIQUIDCASE.NS")

cat > "$OUTDIR/prices.json" <<EOF
{
  "assets": [
    {
      "name": "GoldBeES",
      "price": $GOLD
    },
    {
      "name": "LiquidCase",
      "price": $LIQUID
    }
  ]
}
EOF
