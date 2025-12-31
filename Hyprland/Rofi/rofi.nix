{ pkgs-unstable, pkgs, ... }:

let
  scriptsDir = ./Scripts;
in
{
  # Start wl-gammarelay-rs for external monitor brightness control
  wayland.windowManager.hyprland.settings.exec-once = [
    "wl-gammarelay-rs"
  ];

  # Standalone rofi scripts (not plugins)
  home.packages = with pkgs-unstable; [
    rofi-bluetooth # Run as: rofi-bluetooth
    rofi-network-manager # Run as: rofi-network-manager
    ddgr # DuckDuckGo CLI for search results

    # Dependencies for system control scripts
    brightnessctl # Hardware backlight for internal display
    wl-gammarelay-rs # Software gamma for external monitors
    bc # Calculator for brightness math
    sqlite # For reading browser bookmarks

    # Custom scripts
    (pkgs.writeShellScriptBin "rofi-websearch" (builtins.readFile "${scriptsDir}/websearch.sh"))
    (pkgs.writeShellScriptBin "rofi-max30" (builtins.readFile "${scriptsDir}/max30.sh"))
    (pkgs.writeShellScriptBin "rofi-system" (builtins.readFile "${scriptsDir}/system.sh"))
    (pkgs.writeShellScriptBin "rofi-favorites" (builtins.readFile "${scriptsDir}/favorites.sh"))
  ];

  programs.rofi = {
    enable = true;
    package = pkgs-unstable.rofi;
    terminal = "foot";

    # Actual rofi plugins (loaded via -show)
    plugins = with pkgs-unstable; [
      rofi-calc # rofi -show calc
      rofi-emoji # rofi -show emoji
    ];

    # Modes available in sidebar tabs
    modes = [
      "favorites:rofi-favorites"
      "drun"
      "calc"
      "emoji"
      "max30:rofi-max30"
    ];

    extraConfig = {
      show-icons = true;
      display-system = "";
      display-favorites = "";
      display-drun = "";
      display-calc = "";
      display-emoji = "";
      display-max30 = "";
      drun-display-format = "{name}";
      scroll-method = 0;
      disable-history = false;
      sidebar-mode = false;
      sort = true;
      sorting-method = "fzf";
      matching = "fuzzy";

      # Keybindings (edit as needed)
      kb-primary-paste = "Control+V,Shift+Insert";
      kb-secondary-paste = "Control+v,Insert";
      kb-secondary-copy = "Control+c";
      kb-clear-line = "Control+w";
      kb-move-front = "Control+a";
      kb-move-end = "Control+e";
      kb-move-word-back = "Alt+b,Control+Left";
      kb-move-word-forward = "Alt+f,Control+Right";
      kb-move-char-back = "Control+b";
      kb-move-char-forward = "Control+f";
      kb-remove-word-back = "Control+Alt+h,Control+BackSpace";
      kb-remove-word-forward = "Control+Alt+d";
      kb-remove-char-forward = "Delete,Control+d";
      kb-remove-char-back = "BackSpace,Shift+BackSpace,Control+h";
      kb-remove-to-eol = "";
      kb-remove-to-sol = "Control+u";
      kb-accept-entry = "Return,KP_Enter";
      kb-accept-custom = "Control+Return";
      kb-accept-custom-alt = "Control+Shift+Return";
      kb-accept-alt = "Shift+Return";
      kb-delete-entry = "Shift+Delete";
      kb-mode-next = "Right";
      kb-mode-previous = "Left";
      kb-mode-complete = "Control+l";
      kb-row-left = "Control+Page_Up";
      kb-row-right = "Control+Page_Down";
      kb-row-up = "Up";
      kb-row-down = "Down";
      kb-row-tab = "";
      kb-element-next = "Tab";
      kb-element-prev = "ISO_Left_Tab";
      kb-page-prev = "Page_Up";
      kb-page-next = "Page_Down";
      kb-row-first = "Home,KP_Home";
      kb-row-last = "End,KP_End";
      kb-row-select = "Control+space";
      kb-screenshot = "Alt+S";
      kb-ellipsize = "Alt+period";
      kb-toggle-case-sensitivity = "grave,dead_grave";
      kb-toggle-sort = "Alt+grave";
      kb-cancel = "Escape";
      kb-custom-1 = "1"; # Go back in system menu
    };

    theme =
      let
        mkLiteral = value: {
          _type = "literal";
          value = value;
        };
      in
      {
        window = {
          width = mkLiteral "300px";
          location = mkLiteral "center";
          border-radius = mkLiteral "12px";
          border = mkLiteral "2px solid";
          border-color = mkLiteral "@border-color";
        };
        listview = {
          lines = 8;
          fixed-height = false;
        };
        element = {
          padding = mkLiteral "8px";
          border-radius = mkLiteral "6px";
        };
        "element selected" = {
          border-radius = mkLiteral "6px";
        };
        inputbar = {
          padding = mkLiteral "8px";
        };
      };
  };
}
