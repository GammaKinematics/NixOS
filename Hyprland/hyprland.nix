# Hyprland configuration entry point
# High-level settings: enable, package, imports, and ecosystem packages
{
  pkgs-unstable,
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
    ./Rofi/rofi.nix
    ./KiCad/kicad.nix
    ./waybar.nix
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
    # Image / PDF viewers
    kdePackages.gwenview
    kdePackages.okular

    # File browser
    nautilus
    ffmpegthumbnailer # Video thumbnails for Nautilus

    # Screenshot tools
    grimblast # Screenshot utility for Hyprland

    # Tablet mode tools
    iio-hyprland # Auto-rotate using iio-sensor-proxy
    wvkbd # On-screen keyboard for tablet mode

    # Monitor management
    nwg-displays # GUI for monitor configuration
    hyprland-monitor-attached # Run scripts on monitor hotplug
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # Auto-rotate for tablet mode (iio-sensor-proxy)
      "iio-hyprland"

      # Monitor hotplug handler (creates scripts in ~/.config/hypr/ if needed)
      "hyprland-monitor-attached"
    ];
  };

  # Screenshot annotation tool
  programs.swappy = {
    enable = true;
    package = pkgs-unstable.swappy;
    settings.Default = {
      save_dir = "$HOME/Pictures/Screenshots";
      save_filename_format = "%F_%T.png";
      early_exit = true;
    };
  };

  # Clipboard history manager
  services.cliphist = {
    enable = true;
    package = pkgs-unstable.cliphist;
    allowImages = true;
  };

  # Polkit authentication agent (for privilege escalation dialogs)
  services.hyprpolkitagent = {
    enable = true;
    package = pkgs-unstable.hyprpolkitagent;
  };

  # Blue light filter
  services.hyprsunset = {
    enable = true;
    package = pkgs-unstable.hyprsunset;
  };

  # Auto-start Hyprland on tty1
  programs.bash.profileExtra = ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      exec Hyprland
    fi
  '';
}
