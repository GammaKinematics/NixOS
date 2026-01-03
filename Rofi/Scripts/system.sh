#!/usr/bin/env bash
# Rofi System Menu - as rofi mode with inline submenus
# Uses ROFI_DATA for state tracking between calls
# Supports both Hyprland (Wayland) and dwm (X11)

STATE="${ROFI_DATA:-main}"
SELECTION="$1"

# ==============================================================================
# Environment Detection
# ==============================================================================
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    WM="hyprland"
else
    WM="dwm"
fi

# ==============================================================================
# Helper Functions
# ==============================================================================

get_volume() { wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2*100)}'; }
get_mic_volume() { wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | awk '{print int($2*100)}'; }
is_muted() { wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED && echo "yes" || echo "no"; }
is_mic_muted() { wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED && echo "yes" || echo "no"; }
get_brightness_internal() { brightnessctl -m 2>/dev/null | cut -d',' -f4 | tr -d '%'; }
get_brightness_external() {
    if [[ "$WM" == "hyprland" ]]; then
        local val=$(busctl --user get-property rs.wl-gammarelay /outputs/DP_3 rs.wl.gammarelay Brightness 2>/dev/null | awk '{print $2}')
        echo "${val:-1}" | awk '{print int($1*100)}'
    else
        # X11: Use xrandr gamma (approximate)
        local gamma=$(xrandr --verbose | grep -A5 "DP-3" | grep "Brightness" | awk '{print $2}' 2>/dev/null)
        echo "${gamma:-1}" | awk '{print int($1*100)}'
    fi
}
get_power_profile() { powerprofilesctl get 2>/dev/null || echo "balanced"; }

get_default_sink_id() {
    wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | head -1 | awk '{print $2}' | tr -d ','
}

get_default_source_id() {
    wpctl inspect @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | head -1 | awk '{print $2}' | tr -d ','
}

get_sinks() {
    local default_id=$(get_default_sink_id)
    pw-cli list-objects Node 2>/dev/null | awk '
        /^[[:space:]]*id [0-9]+/ { id = $2; gsub(",", "", id) }
        /node.description = / { gsub(/.*node.description = "|"$/, ""); desc = $0 }
        /media.class = "Audio\/Sink"/ { print id "|" desc }
    ' | while IFS='|' read -r id desc; do
        if [[ "$id" == "$default_id" ]]; then
            echo "✓ ${desc}|${id}"
        else
            echo "${desc}|${id}"
        fi
    done
}

get_sources() {
    local default_id=$(get_default_source_id)
    pw-cli list-objects Node 2>/dev/null | awk '
        /^[[:space:]]*id [0-9]+/ { id = $2; gsub(",", "", id) }
        /node.description = / { gsub(/.*node.description = "|"$/, ""); desc = $0 }
        /media.class = "Audio\/Source"/ { print id "|" desc }
    ' | while IFS='|' read -r id desc; do
        if [[ "$id" == "$default_id" ]]; then
            echo "✓ ${desc}|${id}"
        else
            echo "${desc}|${id}"
        fi
    done
}

# ==============================================================================
# Menu Display Functions
# ==============================================================================

show_main() {
    echo -en "\0data\x1fmain\n"
    echo -en "\0keep-selection\x1ftrue\n"
    echo "󰕾  Sound"
    echo "󰃟  Brightness"
    echo "󰤨  WiFi"
    echo "󰂯  Bluetooth"
    echo "󱐋  Power Profile"
    echo "󰐥  Power"
}

show_sound() {
    echo -en "\0data\x1fsound\n"
    echo -en "\0keep-selection\x1ftrue\n"
    local vol=$(get_volume)
    local mic=$(get_mic_volume)
    local muted=$(is_muted)
    local mic_muted=$(is_mic_muted)
    local vol_icon="󰕾"; [[ "$muted" == "yes" ]] && vol_icon="󰝟"
    local mic_icon="󰍬"; [[ "$mic_muted" == "yes" ]] && mic_icon="󰍭"

    echo "$vol_icon  Volume: ${vol}%"
    echo "󰝝  Volume +5%"
    echo "󰝞  Volume -5%"
    echo "󰓃  Output Device"
    echo "$mic_icon  Mic: ${mic}%"
    echo "󰍮  Mic +5%"
    echo "󰍯  Mic -5%"
    echo "󰍬  Input Device"
    echo "󰁍  Back"
}

show_output() {
    echo -en "\0data\x1foutput\n"
    echo -en "\0keep-selection\x1ftrue\n"
    get_sinks | while IFS='|' read -r name id; do
        echo -en "󰓃  ${name}\0info\x1f${id}\n"
    done
    echo "󰁍  Back"
}

show_input() {
    echo -en "\0data\x1finput\n"
    echo -en "\0keep-selection\x1ftrue\n"
    get_sources | while IFS='|' read -r name id; do
        echo -en "󰍬  ${name}\0info\x1f${id}\n"
    done
    echo "󰁍  Back"
}

show_brightness() {
    echo -en "\0data\x1fbrightness\n"
    echo -en "\0keep-selection\x1ftrue\n"
    local internal=$(get_brightness_internal)
    local external=$(get_brightness_external)

    echo "󰛩  Internal: ${internal}%"
    echo "󰹐  Internal +5%"
    echo "󰹏  Internal -5%"
    echo "󰍹  External: ${external}%"
    echo "󰹐  External +5%"
    echo "󰹏  External -5%"
    echo "󰁍  Back"
}

show_power_profile() {
    echo -en "\0data\x1fprofile\n"
    echo -en "\0keep-selection\x1ftrue\n"
    local current=$(get_power_profile)
    local perf="" bal="" saver=""
    [[ "$current" == "performance" ]] && perf="✓ "
    [[ "$current" == "balanced" ]] && bal="✓ "
    [[ "$current" == "power-saver" ]] && saver="✓ "

    echo "${perf}󱐌  Performance"
    echo "${bal}󰗑  Balanced"
    echo "${saver}󰌪  Power Saver"
    echo "󰢻  Edit Tuning"
    echo "󰁍  Back"
}

show_power() {
    echo -en "\0data\x1fpower\n"
    echo -en "\0keep-selection\x1ftrue\n"
    echo "󰐥  Shutdown"
    echo "󰜉  Reboot"
    echo "󰍃  Logout"
    echo "󰌾  Lock"
    echo "󰁍  Back"
}

# ==============================================================================
# Action Handlers
# ==============================================================================

handle_main() {
    case "$SELECTION" in
        *"Sound"*) show_sound ;;
        *"Brightness"*) show_brightness ;;
        *"WiFi"*) coproc (rofi-network-manager &); exit 0 ;;
        *"Bluetooth"*) coproc (rofi-bluetooth &); exit 0 ;;
        *"Power Profile"*) show_power_profile ;;
        *"Power"*) show_power ;;
        *) show_main ;;
    esac
}

handle_sound() {
    case "$SELECTION" in
        *"Volume:"*) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; show_sound ;;
        *"Volume +5%"*) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0; show_sound ;;
        *"Volume -5%"*) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; show_sound ;;
        *"Output Device"*) show_output ;;
        *"Mic:"*) wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle; show_sound ;;
        *"Mic +5%"*) wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+ -l 1.0; show_sound ;;
        *"Mic -5%"*) wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-; show_sound ;;
        *"Input Device"*) show_input ;;
        *"Back"*) show_main ;;
        *) show_sound ;;
    esac
}

handle_output() {
    case "$SELECTION" in
        *"Back"*) show_sound ;;
        *)
            [[ -n "$ROFI_INFO" ]] && wpctl set-default "$ROFI_INFO"
            show_output
            ;;
    esac
}

handle_input() {
    case "$SELECTION" in
        *"Back"*) show_sound ;;
        *)
            [[ -n "$ROFI_INFO" ]] && wpctl set-default "$ROFI_INFO"
            show_input
            ;;
    esac
}

handle_brightness() {
    case "$SELECTION" in
        *"Internal +5%"*) brightnessctl -q set +5%; show_brightness ;;
        *"Internal -5%"*) brightnessctl -q set 5%-; show_brightness ;;
        *"External +5%"*)
            if [[ "$WM" == "hyprland" ]]; then
                current=$(get_brightness_external)
                new=$((current + 5)); [[ $new -gt 100 ]] && new=100
                val=$(echo "scale=2; $new/100" | bc)
                busctl --user set-property rs.wl-gammarelay /outputs/DP_3 rs.wl.gammarelay Brightness d "$val" 2>/dev/null
            else
                current=$(get_brightness_external)
                new=$((current + 5)); [[ $new -gt 100 ]] && new=100
                val=$(echo "scale=2; $new/100" | bc)
                xrandr --output DP-3 --brightness "$val" 2>/dev/null
            fi
            show_brightness ;;
        *"External -5%"*)
            if [[ "$WM" == "hyprland" ]]; then
                current=$(get_brightness_external)
                new=$((current - 5)); [[ $new -lt 5 ]] && new=5
                val=$(echo "scale=2; $new/100" | bc)
                busctl --user set-property rs.wl-gammarelay /outputs/DP_3 rs.wl.gammarelay Brightness d "$val" 2>/dev/null
            else
                current=$(get_brightness_external)
                new=$((current - 5)); [[ $new -lt 5 ]] && new=5
                val=$(echo "scale=2; $new/100" | bc)
                xrandr --output DP-3 --brightness "$val" 2>/dev/null
            fi
            show_brightness ;;
        *"Back"*) show_main ;;
        *) show_brightness ;;
    esac
}

handle_power_profile() {
    case "$SELECTION" in
        # systemd path watcher auto-applies power-tuning on profile change
        *"Performance"*) powerprofilesctl set performance; show_power_profile ;;
        *"Balanced"*) powerprofilesctl set balanced; show_power_profile ;;
        *"Power Saver"*) powerprofilesctl set power-saver; show_power_profile ;;
        *"Edit Tuning"*) coproc (zeditor "$HOME/NixOS/ryzenadj.nix" &); exit 0 ;;
        *"Back"*) show_main ;;
        *) show_power_profile ;;
    esac
}

handle_power() {
    case "$SELECTION" in
        *"Shutdown"*) systemctl poweroff ;;
        *"Reboot"*) systemctl reboot ;;
        *"Logout"*)
            if [[ "$WM" == "hyprland" ]]; then
                hyprctl dispatch exit
            else
                pkill -x dwm
            fi
            ;;
        *"Lock"*)
            if [[ "$WM" == "hyprland" ]]; then
                hyprlock & exit 0
            else
                slock & exit 0
            fi
            ;;
        *"Back"*) show_main ;;
        *) show_power ;;
    esac
}

# ==============================================================================
# Main Entry Point
# ==============================================================================

if [[ -z "$SELECTION" ]]; then
    case "$STATE" in
        sound) show_sound ;;
        output) show_output ;;
        input) show_input ;;
        brightness) show_brightness ;;
        profile) show_power_profile ;;
        power) show_power ;;
        *) show_main ;;
    esac
else
    case "$STATE" in
        sound) handle_sound ;;
        output) handle_output ;;
        input) handle_input ;;
        brightness) handle_brightness ;;
        profile) handle_power_profile ;;
        power) handle_power ;;
        *) handle_main ;;
    esac
fi
