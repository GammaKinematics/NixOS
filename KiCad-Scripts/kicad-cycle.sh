#!/usr/bin/env bash
# Cycle through KiCad projects (both groups in sync)
# Usage: kicad-cycle.sh [f|b] (forward/backward, default: f)

DIRECTION="${1:-f}"

# Focus workspace 101 and cycle PCB group
hyprctl dispatch workspace 101
hyprctl dispatch changegroupactive "$DIRECTION"

# Focus workspace 102 and cycle schematic group
hyprctl dispatch workspace 102
hyprctl dispatch changegroupactive "$DIRECTION"
