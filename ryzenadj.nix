# RyzenAdj power tuning configuration
# Provides power-tuning script for Minisforum V3 SE power profile management
{ pkgs, ... }:

let
  # Power profiles (values in mW for power, °C for temp)
  profiles = {
    saver = {
      stapm = 15000;
      fast = 18000;
      slow = 16000;
      temp = 80;
    };
    balanced = {
      stapm = 22500;
      fast = 30000;
      slow = 25000;
      temp = 90;
    };
    performance = {
      stapm = 30000;
      fast = 40000;
      slow = 35000;
      temp = 100;
    };
    compile = {
      stapm = 40000;
      fast = 50000;
      slow = 45000;
      temp = 100;
    };
  };

  configFile = pkgs.writeText "power-tuning-config.json" (builtins.toJSON profiles);

  power-tuning = pkgs.writeShellScriptBin "power-tuning" ''
    CONFIG_FILE="${configFile}"
    COMPILE_FLAG="/tmp/.power-tuning-compile-mode"

    # Read a profile from config
    get_profile() {
        local profile="$1"
        ${pkgs.jq}/bin/jq -r ".$profile" "$CONFIG_FILE"
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
        stapm=$(echo "$settings" | ${pkgs.jq}/bin/jq -r '.stapm')
        fast=$(echo "$settings" | ${pkgs.jq}/bin/jq -r '.fast')
        slow=$(echo "$settings" | ${pkgs.jq}/bin/jq -r '.slow')
        temp=$(echo "$settings" | ${pkgs.jq}/bin/jq -r '.temp')

        echo "Applying $profile: STAPM=''${stapm}mW Fast=''${fast}mW Slow=''${slow}mW Temp=''${temp}°C"

        ${pkgs.ryzenadj}/bin/ryzenadj \
            --stapm-limit="$stapm" \
            --fast-limit="$fast" \
            --slow-limit="$slow" \
            --tctl-temp="$temp" \
            2>&1
    }

    # Get current power profile from power-profiles-daemon
    get_current_ppd_profile() {
        local profile
        profile=$(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get 2>/dev/null)

        case "$profile" in
            "power-saver") echo "saver" ;;
            "balanced") echo "balanced" ;;
            "performance") echo "performance" ;;
            *) echo "balanced" ;;
        esac
    }

    # Check if compile mode is active
    is_compile_mode() {
        [[ -f "$COMPILE_FLAG" ]]
    }

    # Main command handling
    case "''${1:-apply}" in
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
            echo "PPD Profile: $(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get 2>/dev/null || echo 'unknown')"
            echo "Compile mode: $(is_compile_mode && echo 'ON' || echo 'OFF')"
            echo ""
            echo "Current presets:"
            ${pkgs.jq}/bin/jq '.' "$CONFIG_FILE"
            ;;

        *)
            echo "Usage: power-tuning {apply|compile-on|compile-off|status}"
            exit 1
            ;;
    esac
  '';
in
{
  # Kernel module for SMU access
  hardware.cpu.amd.ryzen-smu.enable = true;

  # Permissions for ryzenadj to access SMU
  systemd.tmpfiles.rules = [
    "z /sys/kernel/ryzen_smu_drv/smn 0660 root wheel -"
    "z /sys/kernel/ryzen_smu_drv/smu_args 0660 root wheel -"
    "z /sys/kernel/ryzen_smu_drv/mp1_smu_cmd 0660 root wheel -"
    "z /sys/kernel/ryzen_smu_drv/rsmu_cmd 0660 root wheel -"
  ];

  environment.systemPackages = [
    power-tuning
    pkgs.ryzenadj
  ];

  # Apply power tuning on boot and when power profile changes
  systemd.services.power-tuning = {
    description = "Apply RyzenAdj power tuning";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${power-tuning}/bin/power-tuning apply";
    };
  };

  # Re-apply when power profile changes
  systemd.services.power-tuning-on-profile-change = {
    description = "Apply RyzenAdj on power profile change";
    after = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${power-tuning}/bin/power-tuning apply";
    };
  };

  # Path trigger to watch for profile changes
  systemd.paths.power-tuning-watch = {
    description = "Watch for power profile changes";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = "/sys/firmware/acpi/platform_profile";
      Unit = "power-tuning-on-profile-change.service";
    };
  };
}
