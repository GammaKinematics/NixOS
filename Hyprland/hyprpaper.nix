# Hyprpaper - Wallpaper manager configuration
{ config, ... }:

let
  flakeDir = "${config.home.homeDirectory}/NixOS";
in

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;

      # Change the wallpaper filename here
      preload = [ "${flakeDir}/Wallpapers/Shift.png" ];
      wallpaper = [ ", ${flakeDir}/Wallpapers/Shift.png" ];
    };
  };

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "hyprpaper"
    ];
  };
}
