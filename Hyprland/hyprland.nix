# Hyprland configuration entry point
# High-level settings: enable, package, imports, and ecosystem packages
{
  config,
  lib,
  pkgs-unstable,
  inputs,
  ...
}:

{
  imports = [
    ./bindings.nix
    ./settings.nix
    ./monitors.nix
    ./rules.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
    ./mako.nix
    ./walker.nix
    ./Quickshell/quickshell.nix
  ];

  # ============================================================================
  # Hyprland Window Manager
  # ============================================================================
  wayland.windowManager.hyprland = {
    enable = true;

    # Use unstable packages for latest features
    package = pkgs-unstable.hyprland;
    portalPackage = pkgs-unstable.xdg-desktop-portal-hyprland;

    # withUWSM = false;
    xwayland.enable = true;

    # Enable home-manager systemd integration for proper session management
    systemd.enable = true;
  };

  # ============================================================================
  # Hyprland ecosystem packages
  # ============================================================================
  home.packages = with pkgs-unstable; [
    # Hyprland ecosystem
    hyprpicker # Color picker
    hyprsunset # Blue light filter
    hyprpolkitagent # Polkit authentication agent
    inputs.hyprshutdown.packages.x86_64-linux.default # Graceful shutdown

    # File browser
    nautilus

    # Screenshot tools
    grimblast # Screenshot utility for Hyprland

    # Tablet mode tools
    iio-hyprland # Auto-rotate using iio-sensor-proxy
    wvkbd # On-screen keyboard for tablet mode

    # Monitor management
    nwg-displays # GUI for monitor configuration
    hyprland-monitor-attached # Run scripts on monitor hotplug

    # Network management
    networkmanagerapplet # nm-applet for WiFi GUI

    # Clipboard management
    cliphist # Clipboard history manager
    wl-clipboard # wl-copy and wl-paste utilities

    # KiCad script dependencies
    xdotool # Keypress simulation (XWayland)
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "hyprsunset"
      "hyprpolkitagent"

      # NetworkManager applet for WiFi
      "nm-applet --indicator"

      # Clipboard history daemon
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"

      # Auto-rotate for tablet mode (iio-sensor-proxy)
      "iio-hyprland"

      # Monitor hotplug handler (creates scripts in ~/.config/hypr/ if needed)
      "hyprland-monitor-attached"
    ];
  };
}
