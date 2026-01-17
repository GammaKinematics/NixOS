#!/usr/bin/env bash
# Open Symbol + Footprint editors from running schematic/PCB editors
# Supports both Hyprland (Wayland) and dwm (X11)

set -euo pipefail

# ==============================================================================
# Environment Detection
# ==============================================================================
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    WM="hyprland"
else
    WM="dwm"
    PROFILE=$(autorandr --detected 2>/dev/null || echo "mobile")
fi

# ==============================================================================
# Main
# ==============================================================================
if [[ "$WM" == "hyprland" ]]; then
    # Hyprland: Focus workspaces and send keys
    hyprctl dispatch workspace 101
    sleep 0.25
    xdotool key ctrl+u  # Open Footprint Editor from PCB

    sleep 2

    hyprctl dispatch workspace 102
    sleep 0.25
    xdotool key ctrl+i  # Open Symbol Editor from Schematic
else
    # Focus PCB Editor, open Footprint Editor
    [[ "$PROFILE" != "mobile" ]] && echo "mon-prim" > /tmp/dwm.fifo
    echo "kicad" > /tmp/dwm.fifo
    sleep 0.25
    xdotool key ctrl+u

    sleep 0.5

    # Focus right monitor, Schematic Editor, open Symbol Editor
    [[ "$PROFILE" != "mobile" ]] && echo "mon-sec" > /tmp/dwm.fifo
    echo "kicad" > /tmp/dwm.fifo
    sleep 0.25
    xdotool key ctrl+i
fi
