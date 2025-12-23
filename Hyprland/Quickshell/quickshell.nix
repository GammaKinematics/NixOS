{ config, pkgs-unstable, flakeDir, ... }:

let
  colors = config.lib.stylix.colors.withHashtag;
  fonts = config.stylix.fonts;
  quickshellDir = "${flakeDir}/Hyprland/Quickshell";
  # Relative path from home directory (for home.file)
  quickshellRelDir = builtins.replaceStrings [ "${config.home.homeDirectory}/" ] [ "" ] quickshellDir;

  # Theme.qml content generated from Stylix colors
  themeQml = ''
    pragma Singleton
    import Quickshell
    import QtQuick

    Singleton {
      // Base colors (background)
      readonly property color base: "${colors.base00}"
      readonly property color surface0: "${colors.base01}"
      readonly property color surface1: "${colors.base02}"
      readonly property color surface2: "${colors.base03}"

      // Text colors
      readonly property color text: "${colors.base05}"
      readonly property color subtext0: "${colors.base04}"
      readonly property color overlay0: "${colors.base03}"

      // Accent colors
      readonly property color red: "${colors.base08}"
      readonly property color green: "${colors.base0B}"
      readonly property color yellow: "${colors.base0A}"
      readonly property color blue: "${colors.base0D}"
      readonly property color magenta: "${colors.base0E}"
      readonly property color cyan: "${colors.base0C}"
      readonly property color orange: "${colors.base09}"

      // Font settings
      readonly property string fontFamily: "${fonts.monospace.name}"
      readonly property int fontSize: ${toString fonts.sizes.terminal}
    }
  '';
in
{
  # ============================================================================
  # Quickshell - Control Center Widget
  # A popup widget for quick system controls (audio, wifi, bluetooth)
  # Launched on-demand via hotkey ($mod+X)
  # ============================================================================
  programs.quickshell = {
    enable = true;
    package = pkgs-unstable.quickshell;

    # Don't auto-start - launched on-demand via hotkey
    systemd.enable = false;
  };

  # Dependencies for the control center
  home.packages = with pkgs-unstable; [
    bluez # bluetoothctl for bluetooth
    playerctl # Media control
    brightnessctl # Hardware backlight for internal display
    wl-gammarelay-rs # Software gamma for external monitors (DDC fails on Thunderbolt docks)
    glances # System stats (CPU, GPU, RAM, temps) with JSON output
    # ddcutil # External monitor brightness via DDC/CI
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "quickshell -c bar"
      "wl-gammarelay-rs"
    ];
  };
  # Symlink ~/.config/quickshell -> source for live editing
  xdg.configFile."quickshell".source = config.lib.file.mkOutOfStoreSymlink quickshellDir;

  # Generate Theme.qml in each widget's source folder
  home.file = {
    "${quickshellRelDir}/bar/Theme.qml".text = themeQml;
    "${quickshellRelDir}/control-center/Theme.qml".text = themeQml;
  };
}
