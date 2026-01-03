# Waybar - Dynamic config based on connected monitors
# Docked (DP-3): external gets workspaces+clock, internal gets workspaces
# Undocked: internal gets workspaces+clock
{ pkgs-unstable, pkgs, ... }:

let
  workspaceIcons = {
    "terminal" = "";
    "code" = "";
    "browser" = "󰖟";
    "files" = "";
    "video" = "";
    "kicad_prim" = "";
    "kicad_sec" = "";
    "freecad" = "󰻬";
  };

  sharedStyle = ''
    * {
      font-family: "JetBrainsMono Nerd Font Mono", monospace;
    }

    window#waybar {
      background: transparent;
    }

    .modules-left,
    .modules-center,
    .modules-right {
      background: alpha(@theme_bg_color, 0.8);
      border-radius: 8px;
      padding: 2px;
      margin: 0px;
    }

    window#waybar.right .modules-center {
      border-top-right-radius: 0;
      border-bottom-right-radius: 0;
      margin-right: 0;
    }

    window#waybar.left .modules-center {
      border-top-left-radius: 0;
      border-bottom-left-radius: 0;
      margin-left: 0;
    }

    #workspaces {
      padding: 0px;
    }

    .modules-center #workspaces button,
    .modules-left #workspaces button,
    .modules-right #workspaces button {
      padding: 1px 2px;
      min-width: 14px;
      min-height: 12px;
      background: transparent;
      border: none;
      border-bottom: none;
      box-shadow: none;
      text-shadow: none;
      border-radius: 0;
    }

    .modules-center #workspaces button label,
    .modules-left #workspaces button label,
    .modules-right #workspaces button label {
      font-size: 13px;
    }

    .modules-center #workspaces button.active,
    .modules-left #workspaces button.active,
    .modules-right #workspaces button.active {
      color: @base0D;
      border-bottom: none;
      box-shadow: none;
    }

    .modules-center #workspaces button.active label,
    .modules-left #workspaces button.active label,
    .modules-right #workspaces button.active label {
      font-size: 15px;
    }

    #clock {
      padding: 0px;
      font-weight: bold;
    }
  '';

  # JSON config for docked mode (DP-3 primary)
  dockedConfig = builtins.toJSON [
    # DP-3: workspaces on right
    {
      name = "dp3-workspaces";
      output = "DP-3";
      layer = "top";
      exclusive = false;
      passthrough = true;
      position = "right";
      margin-right = 0;
      modules-center = [ "hyprland/workspaces" ];
      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = workspaceIcons;
        show-special = false;
        persistent-workspaces = { };
      };
    }

    # DP-3: clock on left
    {
      name = "dp3-clock";
      output = "DP-3";
      layer = "top";
      exclusive = false;
      passthrough = true;
      position = "left";
      margin-left = 0;
      modules-center = [ "clock" ];
      clock = {
        format = "{:%H\n%M}";
        tooltip-format = "{:%A, %B %d, %Y}";
      };
    }

    # eDP-1: workspaces on left (secondary)
    {
      name = "edp1-workspaces";
      output = "eDP-1";
      layer = "top";
      exclusive = false;
      passthrough = true;
      position = "left";
      margin-left = 0;
      modules-center = [ "hyprland/workspaces" ];
      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = workspaceIcons;
        show-special = false;
        persistent-workspaces = { };
      };
    }
  ];

  # JSON config for undocked mode (eDP-1 only)
  undockedConfig = builtins.toJSON [
    # eDP-1: workspaces on right
    {
      name = "edp1-workspaces";
      output = "eDP-1";
      layer = "top";
      exclusive = false;
      passthrough = true;
      position = "right";
      margin-right = 0;
      modules-center = [ "hyprland/workspaces" ];
      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = workspaceIcons;
        show-special = false;
        persistent-workspaces = { };
      };
    }

    # eDP-1: clock on left
    {
      name = "edp1-clock";
      output = "eDP-1";
      layer = "top";
      exclusive = false;
      passthrough = true;
      position = "left";
      margin-left = 0;
      modules-center = [ "clock" ];
      clock = {
        format = "{:%H\n%M}";
        tooltip-format = "{:%A, %B %d, %Y}";
      };
    }
  ];

  # Simple startup script - check for DP-3 and load appropriate config
  startupScript = ''
    sleep 1
    CONFIG_DIR="$HOME/.config/waybar"

    if hyprctl monitors -j | grep -q '"name": "DP-3"'; then
      waybar -c "$CONFIG_DIR/config-docked.jsonc" &
    else
      waybar -c "$CONFIG_DIR/config-undocked.jsonc" &
    fi
  '';

in
{
  # Waybar - disable systemd, we manage startup ourselves
  programs.waybar = {
    enable = true;
    package = pkgs-unstable.waybar;
    systemd.enable = false;
    style = sharedStyle;
  };

  # Write config files (style via programs.waybar.style to avoid conflict)
  home.file.".config/waybar/config-docked.jsonc".text = dockedConfig;
  home.file.".config/waybar/config-undocked.jsonc".text = undockedConfig;

  # Waybar startup script
  home.packages = [
    (pkgs.writeShellScriptBin "waybar-start" startupScript)
  ];

  # Start waybar
  wayland.windowManager.hyprland.settings.exec-once = [
    "waybar-start"
  ];
}
