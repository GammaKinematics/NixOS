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
    # Tag 16 = kicad (sch/pcb), Tag 17 = kicad PM

    # Switch to PM tag and launch
    echo "mon-sec" > /tmp/dwm.fifo
    echo "kicad-pm" > /tmp/dwm.fifo
    kicad "$PROJECT" &

    # Wait for PM, focus it, open PCB editor
    sleep 3
    xdotool search --name "$PROJECT_NAME" windowactivate --sync
    sleep 0.25
    xdotool key ctrl+p

    # Wait for PCB Editor, focus it, open Schematic
    echo "mon-prim" > /tmp/dwm.fifo
    echo "kicad" > /tmp/dwm.fifo
    sleep 3
    xdotool search --name "PCB Editor" windowactivate --sync
    sleep 0.25
    xdotool key ctrl+e

    # Switch to KiCad work view
    echo "mon-sec" > /tmp/dwm.fifo
    echo "kicad" > /tmp/dwm.fifo
fi
