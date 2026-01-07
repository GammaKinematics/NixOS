#!/usr/bin/env bash
# Show KiCad tag on both monitors
# Supports both Hyprland (Wayland) and dwm (X11)

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
    hyprctl dispatch workspace 101
    hyprctl dispatch workspace 102
else
    if [[ $(autorandr --current) != "mobile" ]]; then
        # Multi-monitor: set kicad tag on both monitors
        echo "mon-prim" > /tmp/dwm.fifo
        echo "kicad" > /tmp/dwm.fifo
        echo "mon-sec" > /tmp/dwm.fifo
        echo "kicad" > /tmp/dwm.fifo
    else
        # Single monitor: just switch to kicad tag
        echo "kicad" > /tmp/dwm.fifo
    fi
fi
