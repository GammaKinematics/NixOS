# Hyprsuck configuration entry point
# Wayland compositor setup with Hyprland
{ pkgs, ... }:

{
  # ============================================================================
  # Hyprland - NixOS level config
  # ============================================================================
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Screenshot tool for Hyprland
    grimblast

    # Tablet mode
    wvkbd
  ];
}
