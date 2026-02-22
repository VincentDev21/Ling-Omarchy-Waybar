#!/usr/bin/env sh

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_FILE="$CACHE_DIR/waybar-weather.json"
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-weather.lock"
FALLBACK='{"text":"-°C","alt":"cloudy","tooltip":"Loading weather..."}'

mkdir -p "$CACHE_DIR"

if [ -s "$CACHE_FILE" ]; then
  cat "$CACHE_FILE"
else
  printf '%s\n' "$FALLBACK"
fi

(
  ( set -C; : > "$LOCK_FILE" ) 2>/dev/null || exit 0
  trap 'rm -f "$LOCK_FILE"' EXIT

  json="$(curl -sS --connect-timeout 2 --max-time 5 'wttr.in?format=j1' | jq -rc '{text:(.current_condition[0].temp_C + "°C"),alt:(.current_condition[0].weatherDesc[0].value|ascii_downcase|if test("thunder") then "thunderstorm" elif test("snow|sleet|blizzard|ice|freezing") then "snow" elif test("rain|drizzle|shower") then "rain" elif test("mist|fog|haze") then "mist" elif test("clear|sun") then "clear-day" elif test("partly") then "partly-cloudy-day" else "cloudy" end),tooltip:(.nearest_area[0].areaName[0].value + ", " + .nearest_area[0].region[0].value + "\n" + .current_condition[0].weatherDesc[0].value + "\nFeels like " + .current_condition[0].FeelsLikeC + "°C")}')" || exit 0

  [ -n "$json" ] || exit 0
  printf '%s\n' "$json" > "$CACHE_FILE"
  pkill -RTMIN+9 waybar >/dev/null 2>&1 || true
) >/dev/null 2>&1 &
