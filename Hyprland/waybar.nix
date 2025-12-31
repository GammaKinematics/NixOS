# Waybar - Minimal bar mimicking Quickshell floating islands
# Styling handled by Stylix, only structure/layout defined here
{ pkgs-unstable, ... }:

let
  # Workspace icon mappings - keys must match workspace NAMES from rules.nix
  workspaceIcons = {
    # Regular workspaces (no defaultName) - show numbers
    # Named workspaces - nerd font icons
    "terminal" = "";
    "code" = ""; # Zed - replace with better icon
    "browser" = "󰖟";
    "files" = "";
    "video" = "";
    "kicad_prim" = ""; # KiCad - replace with better icon
    "kicad_sec" = "";
    "freecad" = "󰻬"; # FreeCAD - replace with better icon
  };

  # Workspaces module config (shared)
  workspacesModule = {
    format = "{icon}";
    format-icons = workspaceIcons;
    show-special = false;
    persistent-workspaces = { };
  };

  # Primary monitor - RIGHT edge: workspaces only
  primaryWorkspaces = {
    output = "DP-3";
    layer = "top";
    exclusive = false;
    passthrough = true;
    position = "right";
    margin-right = 0;

    modules-center = [ "hyprland/workspaces" ];
    "hyprland/workspaces" = workspacesModule;
  };

  # Primary monitor - LEFT edge: clock only
  primaryClock = {
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
  };

  # Secondary monitor (eDP-1): workspaces on left edge
  secondaryWorkspaces = {
    output = "eDP-1";
    layer = "top";
    exclusive = false;
    passthrough = true;
    position = "left";
    margin-left = 0;

    modules-center = [ "hyprland/workspaces" ];
    "hyprland/workspaces" = workspacesModule;
  };

  # Structural CSS - colors from Stylix, images from logoPath
  structureStyle = ''
    /* Transparent window, islands float */
    window#waybar {
      background: transparent;
    }

    /* Semi-transparent island background */
    .modules-left,
    .modules-center,
    .modules-right {
      background: alpha(@theme_bg_color, 0.8);
      border-radius: 8px;
      padding: 2px;
      margin: 0px;
    }

    /* Right-positioned bar: flat edge on right */
    window#waybar.right .modules-center {
      border-top-right-radius: 0;
      border-bottom-right-radius: 0;
      margin-right: 0;
    }

    /* Left-positioned bar: flat edge on left */
    window#waybar.left .modules-center {
      border-top-left-radius: 0;
      border-bottom-left-radius: 0;
      margin-left: 0;
    }

    /* Workspace buttons - must match Stylix specificity */
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

    /* Clock */
    #clock {
      padding: 0px;
      font-weight: bold;
    }
  '';

in
{
  programs.waybar = {
    enable = true;
    package = pkgs-unstable.waybar;
    systemd.enable = true;

    settings = {
      primary-workspaces = primaryWorkspaces;
      primary-clock = primaryClock;
      secondary = secondaryWorkspaces;
    };

    style = structureStyle;
  };
}
