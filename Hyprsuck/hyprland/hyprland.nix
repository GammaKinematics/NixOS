# Hyprland ecosystem configuration (stable packages)
# Core hyprland WM and hypr* tools only
{ pkgs, ... }:

{
  imports = [
    ./bindings.nix
    ./settings.nix
    ./monitors.nix
    ./rules.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
  ];

  # ============================================================================
  # Hyprland Window Manager (home-manager config)
  # ============================================================================
  # Package/portal set at NixOS level in hyprsuck.nix
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
  };

  # ============================================================================
  # Hyprland ecosystem packages (stable)
  # ============================================================================
  home.packages = with pkgs; [
    # Tablet mode
    iio-hyprland

    # Monitor hotplug
    hyprland-monitor-attached
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "iio-hyprland"
      "hyprland-monitor-attached"
    ];
  };

  # Polkit authentication agent
  services.hyprpolkitagent = {
    enable = true;
    package = pkgs.hyprpolkitagent;
  };

  # Blue light filter
  services.hyprsunset = {
    enable = true;
    package = pkgs.hyprsunset;
  };
}
