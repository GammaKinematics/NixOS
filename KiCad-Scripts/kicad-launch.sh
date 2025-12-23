#!/usr/bin/env bash
# Launch KiCad with managed window layout
# Usage: kicad-launch [project.kicad_pro]

set -euo pipefail

PROJECT="${1:-}"

# 1. Focus kicad_sec workspace (102 on eDP-1)
hyprctl dispatch workspace 102

# 2. Launch KiCad (project manager will open on current workspace)
if [[ -n "$PROJECT" ]]; then
    env GDK_BACKEND=x11 kicad "$PROJECT" &
else
    env GDK_BACKEND=x11 kicad &
fi

# 3. Wait for and focus project manager
PM_ADDR=""
for i in {1..50}; do
    PM_ADDR=$(hyprctl clients -j | jq -r '.[] | select(.class == "KiCad" and (.title | test("KiCad 9"))) | .address' 2>/dev/null | head -1)
    [[ -n "$PM_ADDR" ]] && break
    sleep 0.1
done
[[ -z "$PM_ADDR" ]] && exit 1

hyprctl dispatch focuswindow "address:$PM_ADDR"
#sleep 1

# 4. Pop PCB editor (goes to 101/DP-3 via window rules)
xdotool key ctrl+p
sleep 3

# 5. Focus kicad_sec workspace and project manager
hyprctl dispatch workspace 102
hyprctl dispatch focuswindow "address:$PM_ADDR"
#sleep 1

# 6. Pop schematic editor (goes to 102/eDP-1 via window rules)
xdotool key ctrl+e
sleep 1

# 7. Hide project manager
hyprctl dispatch movetoworkspacesilent "special:kicad-pm,address:$PM_ADDR"

# Switch to KiCad workspaces
hyprctl dispatch workspace 101
hyprctl dispatch workspace 102
