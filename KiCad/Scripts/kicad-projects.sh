#!/usr/bin/env bash
# Rofi KiCad project launcher
# Two-step: select folder, then select project
# Works with both Hyprland and dwm

# Define project folders: "Display Name|/path/to/folder"
PROJECT_FOLDERS=(
    "CNC|/data/3D-Printer/Electronics/PCBs"
    "Keyboard|/data/Keyboard/PCB"
    "eGPU|/data/eGPU"
)

# Step 1: Select project folder
FOLDER_MENU=""
for entry in "${PROJECT_FOLDERS[@]}"; do
    FOLDER_MENU+="${entry%%|*}\n"
done

SELECTED_FOLDER=$(echo -e "$FOLDER_MENU" | rofi -dmenu -p "KiCad Folder" -i)
[ -z "$SELECTED_FOLDER" ] && exit 0

# Get the path for selected folder
FOLDER_PATH=""
for entry in "${PROJECT_FOLDERS[@]}"; do
    name="${entry%%|*}"
    path="${entry#*|}"
    if [ "$name" = "$SELECTED_FOLDER" ]; then
        FOLDER_PATH="$path"
        break
    fi
done
[ -z "$FOLDER_PATH" ] && exit 1

# Step 2: Find .kicad_pro files in selected folder
# Sort by path length (shallowest first) to handle submodule duplicates
mapfile -t PROJECTS < <(find "$FOLDER_PATH" -name "*.kicad_pro" -type f 2>/dev/null | awk '{print length, $0}' | sort -n | cut -d' ' -f2-)

if [ ${#PROJECTS[@]} -eq 0 ]; then
    rofi -e "No KiCad projects found in $FOLDER_PATH"
    exit 1
fi

# Build menu with duplicate filtering (keep shallowest path for each project name)
declare -A SEEN_PROJECTS
MENU=""
for project in "${PROJECTS[@]}"; do
    name=$(basename "$project" .kicad_pro)
    # Skip if we've already seen this project name (deeper path = submodule)
    if [ -z "${SEEN_PROJECTS[$name]}" ]; then
        SEEN_PROJECTS[$name]="$project"
        MENU+="$name\n"
    fi
done

# Show rofi menu
SELECTED=$(echo -e "$MENU" | rofi -dmenu -p "Project" -i)
[ -z "$SELECTED" ] && exit 0

# Launch selected project
PROJECT_PATH="${SEEN_PROJECTS[$SELECTED]}"
if [ -n "$PROJECT_PATH" ]; then
    kicad-launch "$PROJECT_PATH"
fi
