# Hyprpaper - Wallpaper manager configuration
{ flakeDir, ... }:

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
