# Hyprlock - Screen locker configuration
{ pkgs-unstable, ... }:

{
  # Disable Stylix's hyprlock theming (we use screenshot blur)
  stylix.targets.hyprlock.enable = false;

  programs.hyprlock = {
    enable = true;
    package = pkgs-unstable.hyprlock;
    settings = {
      general = {
        hide_cursor = true;
        grace = 5; # seconds before lock takes effect
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          outline_thickness = 2;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
  };
}
