#!/bin/bash
set -euo pipefail

cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
cache_file="$cache_home/toggle_animation"
mkdir -p "$cache_home"

if [ -f "$cache_file" ]; then
    hyprctl eval 'hl.config({ animations = { enabled = true } })'
    rm "$cache_file"
else
    hyprctl eval 'hl.config({ animations = { enabled = false } })'
    touch "$cache_file"
fi
