#!/usr/bin/env bash
# Open Symbol + Footprint editors from running schematic/PCB editors
set -euo pipefail

# Focus PCB editor (101) and open Footprint Editor
hyprctl dispatch workspace 101
sleep 0.2
xdotool key ctrl+u

sleep 2

# Focus Schematic editor (102) and open Symbol Editor
hyprctl dispatch workspace 102
sleep 0.2
xdotool key ctrl+i
