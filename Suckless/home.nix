# Suckless home-manager configuration
# X11-specific settings that integrate with home-manager
{ pkgs, ... }:

{
  # Monitor management
  programs.autorandr = {
    enable = true;
    package = pkgs.autorandr;
    hooks.postswitch = {
      "set-xft-dpi" = "echo 'Xft.dpi: 96' | xrdb -merge";
      "set-wallpaper" = ''
        case "$AUTORANDR_CURRENT_PROFILE" in
          docked)
            xwallpaper --output eDP-1 --zoom ~/NixOS/Wallpapers/pearl.jpg --output DP-3 --zoom ~/NixOS/Wallpapers/siege.png
            ;;
          mobile)
            xwallpaper --output eDP-1 --zoom ~/NixOS/Wallpapers/siege.png
            ;;
        esac
      '';
    };
    profiles = {
      "docked" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff002c831207000000001d220104a51e1378025645935e5b9325185054000000010101010101010101010101010101010f3c80a070b0204018303c002ebd10000018000000000000000000000000000000000000000000000000000000000000000000000000000000fe004b443134304e3336333041303100df";
          DP-3 = "00ffffffffffff0061a906b00100000025220103803c2278afa545ad504da6260c5054a5cb0081809500a9c0b300d1c0010101010101023a801871382d40582c450055502100001e000000ff0035333738323030303434353132000000fd0030a561ba3c000a202020202020000000fc005032374642422d52410a20202001c0020319b349010311130414051f90e200ca67030c00100038448e4480a070382d40582c450055502100001e605980a0703814403024350055502100001c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050";
        };
        config = {
          DP-3 = {
            enable = true;
            primary = false;
            mode = "1920x1080";
            rate = "75.00";
            dpi = 96;
            position = "0x180";
          };
          eDP-1 = {
            enable = true;
            primary = true;
            mode = "1920x1200";
            rate = "60.00";
            dpi = 96;
            position = "1920x0";
            rotate = "left";
            scale = {
              x = 0.75;
              y = 0.75;
            };
          };
        };
      };
      "mobile" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff002c831207000000001d220104a51e1378025645935e5b9325185054000000010101010101010101010101010101010f3c80a070b0204018303c002ebd10000018000000000000000000000000000000000000000000000000000000000000000000000000000000fe004b443134304e3336333041303100df";
        };
        config = {
          eDP-1 = {
            enable = true;
            primary = true;
            mode = "1920x1200";
            rate = "60.00";
            dpi = 96;
            position = "0x0";
          };
        };
      };
    };
  };
  services.autorandr = {
    enable = true;
    package = pkgs.autorandr;
  };

  # Screenshots
  services.flameshot = {
    enable = true;
    package = pkgs.flameshot;
  };

  # Touchpad gestures (for mobile mode)
  home.file.".config/libinput-gestures.conf".text = ''
    # 3-finger up/down: tag navigation
    gesture swipe up    3 sh -c 'echo "view-prev" > /tmp/dwm.fifo'
    gesture swipe down  3 sh -c 'echo "view-next" > /tmp/dwm.fifo'

    # 3-finger left/right: window cycling
    gesture swipe left  3 sh -c 'echo "focus-prev" > /tmp/dwm.fifo'
    gesture swipe right 3 sh -c 'echo "focus-next" > /tmp/dwm.fifo'

    # 4-finger up/down: layout
    gesture swipe up    4 sh -c 'echo "layout-mono" > /tmp/dwm.fifo'
    gesture swipe down  4 sh -c 'echo "layout-tile" > /tmp/dwm.fifo'

    # Pinch: rofi system menu / view all
    gesture pinch in  rofi -show system
    gesture pinch out sh -c 'echo "view-all" > /tmp/dwm.fifo'
  '';

  # X11 startup script
  home.file.".xinitrc".text = ''
    # D-Bus environment for GTK apps (fixes slow first launch)
    dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

    # Apply monitor profile
    autorandr --change --default mobile

    # Disable DPMS and screen blanking
    xset s off
    xset -dpms
    xset s noblank

    # Numlock on
    numlockx

    # Status bar
    slstatus &

    # Compositor
    # picom &

    # Touchpad gestures
    libinput-gestures-setup start &

    # Auto-rotate
    auto-rotate &

    # Create dwmfifo for IPC
    mkfifo /tmp/dwm.fifo 2>/dev/null || true

    # Start dwm
    exec dwm
  '';

  # Auto-start X11/dwm on tty1
  programs.bash.profileExtra = ''
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      exec startx
    fi
  '';
}
