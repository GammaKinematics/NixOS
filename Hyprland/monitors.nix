# Hyprland monitor configuration
{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Monitor configuration
    # eDP-1: Laptop display in portrait mode (rotated 270deg)
    # DP-3: External monitor in landscape, positioned to the right
    monitor = [
      "eDP-1, 1920x1200@60, 0x0, 1.25, transform, 3"
      "DP-3, 1920x1080@100, 960x-250, 1"
      ", preferred, auto, 1" # Fallback for any other monitor
    ];
  };
}
