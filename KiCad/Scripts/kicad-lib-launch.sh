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
    # Ensure we're on kicad tag on both monitors
    kicad-show

    # Focus PCB Editor, open Footprint Editor
    sleep 0.5
    xdotool search --name "PCB Editor" windowactivate --sync
    sleep 0.25
    xdotool key ctrl+u

    sleep 3

    # Focus right monitor, Schematic Editor, open Symbol Editor
    xdotool search --name "Schematic Editor" windowactivate --sync
    sleep 0.25
    xdotool key ctrl+i
fi
