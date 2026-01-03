# Suckless home-manager configuration
# X11-specific settings that integrate with home-manager
{ pkgs, ... }:

{
  # Wallpaper management
  programs.feh = {
    enable = true;
    package = pkgs.feh;
  };
  stylix.targets.feh.enable = true;

  # Screenshots
  services.flameshot = {
    enable = true;
    package = pkgs.flameshot;
  };

  # Auto-start X11/dwm on tty1
  programs.bash.profileExtra = ''
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      exec startx
    fi
  '';
}
