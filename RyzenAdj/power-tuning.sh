#!/usr/bin/env bash
#
# power-tuning.sh - RyzenAdj power profile manager for Minisforum V3 SE
#
# Usage:
#   power-tuning.sh apply         Apply settings for current power profile
#   power-tuning.sh compile-on    Enable compile mode (max performance)
#   power-tuning.sh compile-off   Disable compile mode (return to current profile)
#   power-tuning.sh status        Show current status
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"
COMPILE_FLAG="$SCRIPT_DIR/.compile-mode"

# Read a profile from config
get_profile() {
    local profile="$1"
    jq -r ".$profile" "$CONFIG_FILE"
}

# Apply ryzenadj settings
apply_settings() {
    local profile="$1"
    local settings
    settings=$(get_profile "$profile")

    if [[ "$settings" == "null" ]]; then
        echo "Error: Profile '$profile' not found in config"
        return 1
    fi

    local stapm fast slow temp
    stapm=$(echo "$settings" | jq -r '.stapm')
    fast=$(echo "$settings" | jq -r '.fast')
    slow=$(echo "$settings" | jq -r '.slow')
    temp=$(echo "$settings" | jq -r '.temp')

    echo "Applying $profile: STAPM=${stapm}mW Fast=${fast}mW Slow=${slow}mW Temp=${temp}°C"

    ryzenadj \
        --stapm-limit="$stapm" \
        --fast-limit="$fast" \
        --slow-limit="$slow" \
        --tctl-temp="$temp" \
        2>&1
}

# Get current power profile from power-profiles-daemon
get_current_ppd_profile() {
    local profile
    profile=$(powerprofilesctl get 2>/dev/null)

    case "$profile" in
        "power-saver") echo "saver" ;;
        "balanced") echo "balanced" ;;
        "performance") echo "performance" ;;
        *) echo "balanced" ;;  # fallback
    esac
}

# Check if compile mode is active
is_compile_mode() {
    [[ -f "$COMPILE_FLAG" ]]
}

# Main command handling
case "${1:-apply}" in
    apply)
        if is_compile_mode; then
            echo "Compile mode active, using compile profile"
            apply_settings "compile"
        else
            profile=$(get_current_ppd_profile)
            echo "Current PPD profile: $profile"
            apply_settings "$profile"
        fi
        ;;


    compile-on)
        touch "$COMPILE_FLAG"
        echo "Compile mode enabled"
        apply_settings "compile"
        ;;

    compile-off)
        rm -f "$COMPILE_FLAG"
        echo "Compile mode disabled"
        profile=$(get_current_ppd_profile)
        apply_settings "$profile"
        ;;

    status)
        echo "=== Power Tuning Status ==="
        echo "Config file: $CONFIG_FILE"
        echo "PPD Profile: $(powerprofilesctl get 2>/dev/null || echo 'unknown')"
        echo "Compile mode: $(is_compile_mode && echo 'ON' || echo 'OFF')"
        echo ""
        echo "Current presets:"
        jq '.' "$CONFIG_FILE"
        ;;

    *)
        echo "Usage: $0 {apply|compile-on|compile-off|status}"
        exit 1
        ;;
esac
