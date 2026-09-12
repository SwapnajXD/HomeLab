#!/bin/bash

OUT="$HOME/homelab/data/homelab.json"

CPU=$(top -bn1 | awk '/Cpu/{print int($2+$4)}')
RAM=$(free | awk '/Mem:/ {print int($3/$2*100)}')
UPTIME=$(uptime -p | sed 's/up //')

CONTAINERS=$(docker ps -q | wc -l)

PODS=$(kubectl get pods -A --no-headers 2>/dev/null | wc -l)
[ -z "$PODS" ] && PODS=0

check() {
    if curl -fs --max-time 2 "$1" >/dev/null; then
        echo online
    else
        echo offline
    fi
}

ATHENA="online"

if ping -c1 -W1 apollo >/dev/null 2>&1; then
    APOLLO="online"
else
    APOLLO="offline"
fi

HOMEPAGE=$(check http://apollo:3000)
API=$(check http://localhost:8000/olympus)

if tailscale status >/dev/null 2>&1; then
    TAILSCALE="online"
else
    TAILSCALE="offline"
fi

jq -n \
  --argjson cpu "$CPU" \
  --argjson ram "$RAM" \
  --arg uptime "$UPTIME" \
  --argjson containers "$CONTAINERS" \
  --argjson pods "$PODS" \
  --arg athena "$ATHENA" \
  --arg apollo "$APOLLO" \
  --arg homepage "$HOMEPAGE" \
  --arg api "$API" \
  --arg tailscale "$TAILSCALE" \
'{
  cpu:$cpu,
  ram:$ram,
  uptime:$uptime,
  containers:$containers,
  pods:$pods,

  services:{
    athena:$athena,
    apollo:$apollo,
    homepage:$homepage,
    api:$api,
    tailscale:$tailscale
  }
}' > "$OUT"
