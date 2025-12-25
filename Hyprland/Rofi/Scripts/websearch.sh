#!/usr/bin/env bash
# Rofi web search - with DuckDuckGo result preview

# Step 1: Query input (no list)
QUERY=$(echo "" | rofi -dmenu -p "Search  :  " -l 0)
[ -z "$QUERY" ] && exit 0

# Check if input looks like a URL - open directly
if echo "$QUERY" | grep -qE '\.(com|org|net|io|dev|co|me|gov|edu|app|xyz|info)(/|$)'; then
    # Add https:// if no protocol specified
    [[ "$QUERY" =~ ^https?:// ]] || QUERY="https://$QUERY"
    hyprctl dispatch workspace 70
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
            hyprctl dispatch workspace 70
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
            hyprctl dispatch workspace 70
            xdg-open "$URL"
        fi
        ;;
    "Google")
        hyprctl dispatch workspace 70
        xdg-open "https://www.google.com/search?q=$ENCODED"
        ;;
    "MyNixOS")
        hyprctl dispatch workspace 70
        xdg-open "https://mynixos.com/search?q=$ENCODED"
        ;;
    "Nixpkgs")
        hyprctl dispatch workspace 70
        xdg-open "https://search.nixos.org/packages?query=$ENCODED"
        ;;
esac
