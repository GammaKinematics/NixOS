#!/usr/bin/env bash
# Rofi Max30 mode - list and open video files with custom names

VIDEOS=(
    "Max Out Cardio|/data-bis/Insanity MAX 30/Max Out Cardio.mkv"
    "Max Out Power|/data-bis/Insanity MAX 30/Max Out Power.mkv"
    "Max Out Sweat|/data-bis/Insanity MAX 30/Max Out Sweat.mkv"
    "Max Out Strength|/data-bis/Insanity MAX 30/Max Out Strength.mkv"
    "Friday Fight #2|/data-bis/Insanity MAX 30/Friday Fight Round 2.mkv"
)

# If no argument, list video names
if [ -z "$1" ]; then
    for entry in "${VIDEOS[@]}"; do
        echo "${entry%%|*}"
    done
    exit 0
fi

# If argument provided, find and open the matching video
SELECTED="$1"
for entry in "${VIDEOS[@]}"; do
    name="${entry%%|*}"
    path="${entry#*|}"
    if [ "$name" = "$SELECTED" ]; then
        setsid xdg-open "$path" >/dev/null 2>&1 &
        hyprctl dispatch workspace 90 >/dev/null 2>&1
        exit 0
    fi
done
