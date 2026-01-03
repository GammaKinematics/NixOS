#!/usr/bin/env bash
# Swap KiCad workspaces between monitors
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
    hyprctl dispatch swapactiveworkspaces DP-3 eDP-1
else
    # dwm: Use swapmon function (mod+shift+')
    xdotool key super+shift+apostrophe
fi
