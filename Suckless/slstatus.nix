# slstatus - suckless status bar
{ pkgs, ... }:

let
  # Dynamic icon scripts
  batteryScript = pkgs.writeShellScript "slstatus-battery" ''
    perc=$(cat /sys/class/power_supply/BATT/capacity 2>/dev/null || echo "0")
    status=$(cat /sys/class/power_supply/BATT/status 2>/dev/null || echo "Unknown")

    if [ "$status" = "Charging" ]; then
      icon="󰂄"
    elif [ "$perc" -ge 90 ]; then icon="󰁹"
    elif [ "$perc" -ge 80 ]; then icon="󰂂"
    elif [ "$perc" -ge 70 ]; then icon="󰂁"
    elif [ "$perc" -ge 60 ]; then icon="󰂀"
    elif [ "$perc" -ge 50 ]; then icon="󰁿"
    elif [ "$perc" -ge 40 ]; then icon="󰁾"
    elif [ "$perc" -ge 30 ]; then icon="󰁽"
    elif [ "$perc" -ge 20 ]; then icon="󰁼"
    elif [ "$perc" -ge 10 ]; then icon="󰁻"
    else icon="󰁺"
    fi

    printf "%s %s%%" "$icon" "$perc"
  '';

  mouseScript = pkgs.writeShellScript "slstatus-mouse" ''
    perc=$(cat /sys/class/power_supply/hidpp_battery_0/capacity 2>/dev/null || echo "")
    [ -z "$perc" ] && exit 0
    printf "󰍽 %s%%" "$perc"
  '';

  volumeScript = pkgs.writeShellScript "slstatus-volume" ''
    vol=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    muted=$(echo "$vol" | grep -c MUTED)
    perc=$(echo "$vol" | awk '{printf "%.0f", $2*100}')

    if [ "$muted" -eq 1 ]; then icon="󰝟"
    elif [ "$perc" -ge 66 ]; then icon="󰕾"
    elif [ "$perc" -ge 33 ]; then icon="󰖀"
    else icon="󰕿"
    fi

    printf "%s %s%%" "$icon" "$perc"
  '';

  wifiScript = pkgs.writeShellScript "slstatus-wifi" ''
    essid=$(cat /sys/class/net/wlp2s0/wireless/../uevent 2>/dev/null | grep INTERFACE | cut -d= -f2)
    essid=$(${pkgs.iw}/bin/iw dev wlp2s0 link 2>/dev/null | grep SSID | awk '{print $2}')
    [ -z "$essid" ] && exit 0

    perc=$(awk 'NR==3 {printf "%.0f", $3*100/70}' /proc/net/wireless 2>/dev/null || echo "0")

    if [ "$perc" -ge 75 ]; then icon="󰤥"
    elif [ "$perc" -ge 50 ]; then icon="󰤢"
    elif [ "$perc" -ge 25 ]; then icon="󰤟"
    else icon="󰤯"
    fi

    printf "%s %s %s%%" "$icon" "$essid" "$perc"
  '';

  config = ''
    /* See LICENSE file for copyright and license details. */

    /* interval between updates (in ms) */
    const unsigned int interval = 1000;

    /* text to show if no value can be retrieved */
    static const char unknown_str[] = "";

    /* maximum output string length */
    #define MAXLEN 512

    static const struct arg args[] = {
    	/* function        format          argument */
    	{ cpu_freq,        " %s/",        NULL },
    	{ cpu_perc,        "%s%% | ",      NULL },
    	{ ram_used,        " %s/",        NULL },
    	{ ram_perc,        "%s%% | ",      NULL },
    	{ temp,            " %s°C | ",    "/sys/class/thermal/thermal_zone0/temp" },
    	{ run_command,     "%s | ",        "${wifiScript}" },
    	{ run_command,     "%s | ",        "${volumeScript}" },
    	{ run_command,     "%s | ",        "${batteryScript}" },
    	{ run_command,     "%s | ",        "${mouseScript}" },
    	{ datetime,        " %s ",       "%d/%m %H:%M:%S" },
    };
  '';
in
{
  environment.systemPackages = [
    (pkgs.slstatus.override { conf = config; })
  ];
}
