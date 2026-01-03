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
    # dwm: Focus each monitor and send keys
    # PCB on monitor 0 (left), Schematic on monitor 1 (right)
    xdotool key super+k
    sleep 0.25

    xdotool key super+Left
    sleep 0.25
    xdotool key ctrl+u  # Open Footprint Editor from PCB

    sleep 2

    xdotool key super+Right
    sleep 0.25
    xdotool key ctrl+i  # Open Symbol Editor from Schematic
fi
