# Hyprpaper - Wallpaper manager configuration
{ config, pkgs-unstable, ... }:

let
  flakeDir = "${config.home.homeDirectory}/NixOS";
in

{
  services.hyprpaper = {
    enable = true;
    package = pkgs-unstable.hyprpaper;
    settings = {
      ipc = "on";
      splash = false;

      # Change the wallpaper filename here
      preload = [ "${flakeDir}/Wallpapers/Shift.png" ];
      wallpaper = [ ", ${flakeDir}/Wallpapers/Shift.png" ];
    };
  };

}
