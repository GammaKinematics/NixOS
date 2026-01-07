#!/usr/bin/env bash
# Rofi Max30 mode - list and open video files with custom names
# Supports both Hyprland (Wayland) and dwm (X11)

# ==============================================================================
# Environment Detection
# ==============================================================================
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    WM="hyprland"
else
    WM="dwm"
fi

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
        if [[ "$WM" == "hyprland" ]]; then
            hyprctl dispatch workspace 90 >/dev/null 2>&1
        else
            # Focus primary monitor first if not on mobile (single monitor) profile
            [[ $(autorandr --current) != "mobile" ]] && echo "mon-prim" > /tmp/dwm.fifo
            echo "video" > /tmp/dwm.fifo
        fi
        exit 0
    fi
done
