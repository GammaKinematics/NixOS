#!/usr/bin/env bash
# Launch KiCad with managed window layout
# Usage: kicad-launch <project.kicad_pro>

set -euo pipefail

PROJECT="${1:-}"
if [[ -z "$PROJECT" ]]; then
    echo "Usage: kicad-launch <project.kicad_pro>"
    exit 1
fi

PROJECT_NAME=$(basename "$PROJECT" .kicad_pro)

# 1. Show special workspace for PM
hyprctl dispatch workspace 102
hyprctl dispatch togglespecialworkspace kicad-pm

# 2. Launch KiCad directly on special workspace
hyprctl dispatch exec "[workspace special:kicad-pm silent]" -- env GDK_BACKEND=x11 kicad "$PROJECT"

# 3. Wait for project manager window
PM_ADDR=""
for i in {1..50}; do
    PM_ADDR=$(hyprctl clients -j | jq -r --arg name "$PROJECT_NAME" \
        '.[] | select(.class == "KiCad" and (.title | test($name))) | .address' 2>/dev/null | head -1)
    [[ -n "$PM_ADDR" ]] && break
    sleep 0.1
done

if [[ -z "$PM_ADDR" ]]; then
    hyprctl dispatch togglespecialworkspace kicad-pm
    echo "Failed to find KiCad project manager window"
    exit 1
fi

# 4. Focus PM and open PCB editor
hyprctl dispatch focuswindow "address:$PM_ADDR"
sleep 0.25
xdotool key ctrl+p
sleep 0.25

# 5. Hide special workspace (PM stays there)
hyprctl dispatch togglespecialworkspace kicad-pm

# 6. Focus PCB editor (on 101) and open schematic from it
sleep 2
hyprctl dispatch workspace 101
sleep 0.25
xdotool key ctrl+e
sleep 0.25

# 7. Switch to KiCad workspaces
hyprctl dispatch workspace 101
hyprctl dispatch workspace 102
