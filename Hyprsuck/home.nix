# Hyprsuck home-manager configuration
# Unstable extras and autostart
{ pkgs-unstable, ... }:

{
  imports = [
    ./hyprland/hyprland.nix
    ./waybar.nix
  ];

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

  # Terminal emulator (Wayland-native)
  programs.foot = {
    enable = true;
    package = pkgs-unstable.foot;
  };

  # Auto-start Hyprland on tty1
  programs.bash.profileExtra = ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      exec Hyprland
    fi
  '';
}
