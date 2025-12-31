#!/usr/bin/env bash
# Rofi Favorites - Reads Zen/Firefox bookmarks directly from SQLite
# Supports folder navigation with ROFI_DATA state tracking

PLACES_DB="$HOME/.zen/default/places.sqlite"
TEMP_DB="/tmp/rofi-bookmarks.sqlite"
STATE="${ROFI_DATA:-3}"  # 3 = Bookmarks Toolbar folder ID
SELECTION="$1"
RETV="${ROFI_RETV:-0}"

# Copy database to avoid lock issues (browser keeps it locked)
cp "$PLACES_DB" "$TEMP_DB" 2>/dev/null

# Handle back key (kb-custom-1)
if [[ "$RETV" == "10" ]]; then
    if [[ "$STATE" == "3" ]]; then
        exit 0
    else
        # Get parent folder
        parent=$(sqlite3 "$TEMP_DB" "SELECT parent FROM moz_bookmarks WHERE id = $STATE;")
        [[ -z "$parent" || "$parent" == "0" || "$parent" == "1" ]] && parent=3
        echo -en "\0data\x1f${parent}\n"
        show_folder "$parent"
        exit 0
    fi
fi

show_folder() {
    local folder_id="$1"
    echo -en "\0data\x1f${folder_id}\n"
    echo -en "\0keep-selection\x1ftrue\n"

    # Show back option if not at root
    [[ "$folder_id" != "3" ]] && echo "󰁍  .."

    # Query bookmarks in this folder
    # type 1 = bookmark, type 2 = folder
    sqlite3 -separator '|' "$TEMP_DB" "
        SELECT
            b.id,
            b.type,
            COALESCE(b.title, ''),
            COALESCE(p.url, '')
        FROM moz_bookmarks b
        LEFT JOIN moz_places p ON b.fk = p.id
        WHERE b.parent = $folder_id
          AND b.title IS NOT NULL
          AND b.title != ''
        ORDER BY b.position;
    " | while IFS='|' read -r id type title url; do
        if [[ "$type" == "2" ]]; then
            # Folder
            echo -en "󰉋  ${title}\0info\x1ffolder:${id}\n"
        elif [[ "$type" == "1" && -n "$url" ]]; then
            # Bookmark
            echo -en "󰈙  ${title}\0info\x1f${url}\n"
        fi
    done
}

handle_selection() {
    local info="$ROFI_INFO"

    # Back/parent
    if [[ "$SELECTION" == "󰁍  .." ]]; then
        parent=$(sqlite3 "$TEMP_DB" "SELECT parent FROM moz_bookmarks WHERE id = $STATE;")
        [[ -z "$parent" || "$parent" == "0" || "$parent" == "1" ]] && parent=3
        show_folder "$parent"
        return
    fi

    # Folder - navigate into it
    if [[ "$info" == folder:* ]]; then
        local folder_id="${info#folder:}"
        show_folder "$folder_id"
        return
    fi

    # URL - open it
    if [[ -n "$info" && "$info" != folder:* ]]; then
        coproc (xdg-open "$info" &)
        exit 0
    fi

    show_folder "$STATE"
}

# Check if database exists
if [[ ! -f "$PLACES_DB" ]]; then
    echo "󰀨  No Zen browser profile found"
    echo "󰈙  Expected: ~/.zen/default/places.sqlite"
    exit 0
fi

# Main entry
if [[ -z "$SELECTION" ]]; then
    show_folder "$STATE"
else
    handle_selection
fi
