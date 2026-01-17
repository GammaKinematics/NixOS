# Suckless configuration entry point
# X11 window manager setup with dwm, st, and related tools
{ pkgs, ... }:

{
  imports = [
    ./dwm/dwm.nix
    ./st/st.nix
    ./slstatus.nix
  ];

  # ============================================================================
  # X11 Display Server
  # ============================================================================
  services.xserver = {
    enable = true;

    # Keyboard layout
    xkb.layout = "us";

    displayManager.startx.enable = true;

    # Auto-lock after 10 minutes of inactivity
    xautolock = {
      enable = true;
      time = 10;
      locker = "${pkgs.slock}/bin/slock";
    };
  };

  # Input (libinput)
  services.libinput.enable = true;

  # Tablet/stylus support
  services.xserver.wacom.enable = true;

  # Accelerometer for auto-rotation
  hardware.sensor.iio.enable = true;

  # ============================================================================
  # Screen Locker
  # ============================================================================
  programs.slock = {
    enable = true;
    package = pkgs.slock;
  };

  # ============================================================================
  # XDG Portal for X11
  # ============================================================================
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  # ============================================================================
  # X11 ecosystem packages
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # Clipboard
    xclip

    # Wallpaper
    xwallpaper

    # Numlock on startup
    numlockx

    # Touchpad gestures
    libinput-gestures

    # Auto-rotate based on accelerometer (with wallpaper switching, mobile only)
    (writeShellScriptBin "auto-rotate" ''
      export DISPLAY=''${DISPLAY:-:0}
      WALLPAPER_DIR="$HOME/NixOS/Wallpapers"

      ${iio-sensor-proxy}/bin/monitor-sensor | while read -r line; do
        # Skip rotation when docked (would mess up monitor positions)
        [[ $(${autorandr}/bin/autorandr --detected) != "mobile" ]] && continue

        case "$line" in
          *"normal"*)
            ${xorg.xrandr}/bin/xrandr --output eDP-1 --rotate normal
            ${xwallpaper}/bin/xwallpaper --output eDP-1 --zoom "$WALLPAPER_DIR/siege.png"
            ;;
          *"left-up"*)
            ${xorg.xrandr}/bin/xrandr --output eDP-1 --rotate left
            ${xwallpaper}/bin/xwallpaper --output eDP-1 --zoom "$WALLPAPER_DIR/pearl.jpg"
            ;;
          *"right-up"*)
            ${xorg.xrandr}/bin/xrandr --output eDP-1 --rotate right
            ${xwallpaper}/bin/xwallpaper --output eDP-1 --zoom "$WALLPAPER_DIR/pearl.jpg"
            ;;
          *"bottom-up"*)
            ${xorg.xrandr}/bin/xrandr --output eDP-1 --rotate inverted
            ${xwallpaper}/bin/xwallpaper --output eDP-1 --zoom "$WALLPAPER_DIR/siege.png"
            ;;
        esac
      done
    '')
  ];

  # ============================================================================
  # Polkit authentication agent
  # ============================================================================
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
