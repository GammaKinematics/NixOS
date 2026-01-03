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
    displayManager.startx = {
      enable = true;
      extraCommands = ''
        # Status bar
        slstatus &
      '';
    };

    # Auto-lock after 10 minutes of inactivity
    xautolock = {
      enable = true;
      time = 10;
      locker = "${pkgs.slock}/bin/slock";
    };
  };

  # ============================================================================
  # Screen Locker
  # ============================================================================
  programs.slock = {
    enable = true;
    package = pkgs.slock;
  };

  # ============================================================================
  # X11 ecosystem packages
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # Clipboard
    xclip
  ];

  # ============================================================================
  # Display hotplug management
  # ============================================================================
  services.autorandr = {
    enable = true;
    hooks.postswitch = {
      "restart-slstatus" = "pkill slstatus; slstatus &";
    };
  };

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
