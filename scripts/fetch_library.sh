#!/bin/sh

OUTDIR="$HOME/homelab/data"
mkdir -p "$OUTDIR"

cat > "$OUTDIR/library.json" <<EOF
{
  "title": "The Pragmatic Programmer",
  "progress": "42%"
}
