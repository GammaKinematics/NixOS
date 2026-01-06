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

  # Monitor management
  programs.autorandr = {
    enable = true;
    package = pkgs.autorandr;
    hooks.postswitch = {
      "set-xft-dpi" = "echo 'Xft.dpi: 96' | xrdb -merge";
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
            position = "0x0";
          };
          eDP-1 = {
            enable = true;
            primary = true;
            mode = "1920x1200";
            rate = "60.00";
            dpi = 96;
            position = "1920x0";
            rotate = "right";
            # scale = {
            #   x = 0.8;
            #   y = 0.8;
            # };
          };
        };
      };
      "mobile" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff002c831207000000001d220104a51e1378025645935e5b9325185054000000010101010101010101010101010101010f3c80a070b0204018303c002ebd10000018000000000000000000000000000000000000000000000000000000000000000000000000000000fe004b443134304e3636333041303100df";
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

  # Compositor for transparency
  services.picom = {
    enable = true;
    package = pkgs.picom;
    backend = "glx";
    vSync = true;
    activeOpacity = 0.9;
    inactiveOpacity = 0.8;
    menuOpacity = 0.5;
    opacityRules = [
      "100:fullscreen"
      "100:class_g = 'dwm'"
      "100:window_type = 'dock'"
    ];
    settings = {
      corner-radius = 10;
    };
  };

  # X11 startup script
  home.file.".xinitrc".text = ''
    # D-Bus environment for GTK apps (fixes slow first launch)
    dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

    # Apply monitor profile
    autorandr --change --default mobile

    # Numlock on
    numlockx

    # Status bar
    slstatus &

    # Compositor
    picom &

    # Wallpaper (DP-3: norse, eDP-1: pearl)
    feh --bg-fill ~/NixOS/Wallpapers/pearl.jpg --bg-fill ~/NixOS/Wallpapers/siege.png

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
