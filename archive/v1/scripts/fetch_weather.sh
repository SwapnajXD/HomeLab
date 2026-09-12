#!/bin/sh

OUTDIR="$HOME/homelab/data"
mkdir -p "$OUTDIR"

CITY="Nagpur"

WEATHER_RAW=$(curl -s "https://wttr.in/${CITY}?format=j1")

TEMP=$(echo "$WEATHER_RAW" | jq -r '.current_condition[0].temp_C // "0"')
FEELS=$(echo "$WEATHER_RAW" | jq -r '.current_condition[0].FeelsLikeC // "0"')
DESC=$(echo "$WEATHER_RAW" | jq -r '.current_condition[0].weatherDesc[0].value // "Unknown"')
HUMIDITY=$(echo "$WEATHER_RAW" | jq -r '.current_condition[0].humidity // "0"')

SUMMARY="Weather looks normal today."

case "$DESC" in
    *Thunder*|*Rain*)
        SUMMARY="Carry an umbrella."
        ;;
    *Haze*)
        SUMMARY="Hot and hazy conditions today."
        ;;
    *Clear*)
        SUMMARY="Clear skies today."
        ;;
esac

# Override summary if it feels very hot
if [ "$FEELS" -ge 42 ] 2>/dev/null; then
    SUMMARY="Very hot today — stay hydrated."
fi

jq -n \
    --arg city "$CITY" \
    --arg temp "$TEMP" \
    --arg feels "$FEELS" \
    --arg condition "$DESC" \
    --arg humidity "$HUMIDITY" \
    --arg summary "$SUMMARY" \
    --arg updated "$(date '+%H:%M')" \
    '{
        city: $city,
        temperature: ($temp | tonumber),
        feels_like: ($feels | tonumber),
        condition: $condition,
        humidity: ($humidity | tonumber),
        summary: $summary,
        updated: $updated
    }' > "$OUTDIR/weather.json"
