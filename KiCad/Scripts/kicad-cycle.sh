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
    # Ensure we're on kicad tag on both monitors first
    kicad-show

    # Determine focus direction
    FOCUS_CMD="focus-next"
    [[ "$DIRECTION" == "b" ]] && FOCUS_CMD="focus-prev"

    if [[ $(autorandr --detected) != "mobile" ]]; then
        # Multi-monitor: cycle on both monitors
        echo "mon-prim" > /tmp/dwm.fifo
        echo "$FOCUS_CMD" > /tmp/dwm.fifo
        echo "mon-sec" > /tmp/dwm.fifo
        echo "$FOCUS_CMD" > /tmp/dwm.fifo
    else
        # Single monitor: just cycle windows
        echo "$FOCUS_CMD" > /tmp/dwm.fifo
    fi
fi
