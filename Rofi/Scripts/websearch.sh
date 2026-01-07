#!/usr/bin/env bash
# Rofi web search - with DuckDuckGo result preview
# Supports both Hyprland (Wayland) and dwm (X11)

# ==============================================================================
# Environment Detection
# ==============================================================================
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    WM="hyprland"
else
    WM="dwm"
fi

switch_to_browser() {
    if [[ "$WM" == "hyprland" ]]; then
        hyprctl dispatch workspace 70
    else
        # Focus primary monitor first if not on mobile (single monitor) profile
        [[ $(autorandr --current) != "mobile" ]] && echo "mon-prim" > /tmp/dwm.fifo
        echo "browser" > /tmp/dwm.fifo
    fi
}

# Step 1: Query input (no list)
QUERY=$(echo "" | rofi -dmenu -p "Search  :  " -l 0)
[ -z "$QUERY" ] && exit 0

# Check if input looks like a URL - open directly
if echo "$QUERY" | grep -qE '\.(com|org|net|io|dev|co|me|gov|edu|app|xyz|info)(/|$)'; then
    # Add https:// if no protocol specified
    [[ "$QUERY" =~ ^https?:// ]] || QUERY="https://$QUERY"
    switch_to_browser
    xdg-open "$QUERY"
    exit 0
fi

# Step 2: Engine selection (DuckDuckGo first)
ENGINE=$(printf "  DuckDuckGo\n  Google\n  MyNixOS\n  Nixpkgs" | rofi -dmenu -p "Engine :  " -no-custom -l 4)
[ -z "$ENGINE" ] && exit 0

# Remove icon prefix
ENGINE="${ENGINE#*  }"

ENCODED=$(echo "$QUERY" | sed 's/ /%20/g; s/&/%26/g; s/?/%3F/g; s/=/%3D/g')

case "$ENGINE" in
    "DuckDuckGo")
        # Fetch top 5 results using ddgr
        RESULTS=$(ddgr --json -n 5 "$QUERY" 2>/dev/null | jq -r '.[] | "\(.title)\t\(.url)"')

        if [ -z "$RESULTS" ]; then
            # Fallback to direct search if no results
            switch_to_browser
            xdg-open "https://duckduckgo.com/?q=$ENCODED"
            exit 0
        fi

        # Show results in rofi (title only)
        TITLES=$(echo "$RESULTS" | cut -f1)
        SELECTED=$(echo "$TITLES" | rofi -dmenu -p "Results :  " -l 5)
        [ -z "$SELECTED" ] && exit 0

        # Get URL for selected title
        URL=$(echo "$RESULTS" | grep "^$SELECTED	" | cut -f2)
        if [ -n "$URL" ]; then
            switch_to_browser
            xdg-open "$URL"
        fi
        ;;
    "Google")
        switch_to_browser
        xdg-open "https://www.google.com/search?q=$ENCODED"
        ;;
    "MyNixOS")
        switch_to_browser
        xdg-open "https://mynixos.com/search?q=$ENCODED"
        ;;
    "Nixpkgs")
        switch_to_browser
        xdg-open "https://search.nixos.org/packages?query=$ENCODED"
        ;;
esac
