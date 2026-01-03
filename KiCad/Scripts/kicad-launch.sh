#!/usr/bin/env bash
# Launch KiCad with managed window layout
# Usage: kicad-launch <project.kicad_pro>
# Supports both Hyprland (Wayland) and dwm (X11)

set -euo pipefail

# ==============================================================================
# Environment Detection
# ==============================================================================
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    WM="hyprland"
else
    WM="dwm"
fi

# ==============================================================================
# Main
# ==============================================================================
PROJECT="${1:-}"
if [[ -z "$PROJECT" ]]; then
    echo "Usage: kicad-launch <project.kicad_pro>"
    exit 1
fi

PROJECT_NAME=$(basename "$PROJECT" .kicad_pro)

if [[ "$WM" == "hyprland" ]]; then
    # Hyprland: Use special workspace for PM
    hyprctl dispatch workspace 102
    hyprctl dispatch togglespecialworkspace kicad-pm
    hyprctl dispatch exec "[workspace special:kicad-pm silent]" -- env GDK_BACKEND=x11 kicad "$PROJECT"

    # Wait for project manager window
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

    # Focus PM and open PCB editor
    hyprctl dispatch focuswindow "address:$PM_ADDR"
    sleep 0.25
    xdotool key ctrl+p
    sleep 0.25

    # Hide special workspace
    hyprctl dispatch togglespecialworkspace kicad-pm

    # Focus PCB editor and open schematic
    sleep 2
    hyprctl dispatch workspace 101
    sleep 0.25
    xdotool key ctrl+e
    sleep 0.25

    # Switch to KiCad workspaces
    hyprctl dispatch workspace 101
    hyprctl dispatch workspace 102

else
    # dwm: Launch KiCad, window rules handle placement
    # Tag 15 = PM, Tag 16 = PCB, Tag 17 = Schematic

    # Switch to PM tag and launch
    xdotool key super+k
    sleep 0.25
    xdotool key super+ctrl+k
    sleep 0.25
    kicad "$PROJECT" &

    # Wait for PM to open, then open PCB editor
    sleep 2
    xdotool key ctrl+p

    # Switch to KiCad view (PCB + Schematic)
    sleep 1
    xdotool key super+k

    # Wait for PCB to open, then open schematic
    sleep 2
    xdotool key ctrl+e

fi
