#!/usr/bin/env bash

set -u

bars="▁▂▃▄▅▆▇█"
sed_map='s/;//g;'

for ((index = 0; index < ${#bars}; index++)); do
    sed_map+="s/${index}/${bars:index:1}/g;"
done

config_file="$(mktemp /tmp/waybar-cava.XXXXXX)"
trap 'rm -f "$config_file"' EXIT

cat > "$config_file" <<'EOF'
[general]
bars = 18
autosens = 0
sensitivity = 2200

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

cava -p "$config_file" | while IFS= read -r line; do
    printf '%s\n' "$line" | sed "$sed_map"
done