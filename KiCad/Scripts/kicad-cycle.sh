#!/usr/bin/env bash
# Cycle through KiCad windows/projects
# Usage: kicad-cycle [f|b] (forward/backward, default: f)
# Supports both Hyprland (Wayland) and dwm (X11)

DIRECTION="${1:-f}"

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
    # Hyprland: Cycle through groups on both workspaces
    hyprctl dispatch workspace 101
    hyprctl dispatch changegroupactive "$DIRECTION"
    hyprctl dispatch workspace 102
    hyprctl dispatch changegroupactive "$DIRECTION"
else
    # dwm: Cycle tabbed windows on both monitors (PCB on mon 0, Schematic on mon 1)
    KEY="super+Down"
    [[ "$DIRECTION" == "b" ]] && KEY="super+Up"

    xdotool key super+Left && xdotool key $KEY && xdotool key super+Right && xdotool key $KEY
fi
