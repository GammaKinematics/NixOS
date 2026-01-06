# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix
    # ./Hyprsuck/hyprsuck.nix
    ./Suckless/suckless.nix # Uncomment for dwm (and comment Hyprsuck)
    ./ryzenadj.nix
    # ./virtualisation.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Required for home-manager xdg.portal with useUserPackages
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # Bootloader (stable)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.timeout = 1;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Autologin to TTY (Hyprland started via shell profile with UWSM)
  services.getty.autologinUser = "lebowski";

  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.settings.General.Numlock = "on";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.lebowski = {
    isNormalUser = true;
    description = "Antoine Lespinasse";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # services.flatpak.enable = true;

  # GVfs - for Nautilus trash, network shares, MTP devices
  services.gvfs.enable = true;

  # UPower - battery/power device monitoring
  services.upower.enable = true;

  # Power Profiles Daemon - power management (performance/balanced/power-saver)
  services.power-profiles-daemon.enable = true;

  # Enable nix-ld for dynamically linked binaries (e.g., Zed LSP servers)
  programs.nix-ld.enable = true;

  # Firefox (kept as backup browser, zen-browser is in home-manager)
  programs.firefox.enable = true;

  # System packages (stable for core tools)
  environment.systemPackages = with pkgs; [
    wget
    git
    bat
    btop
    neofetch
    xdotool
    jq

    # Disk utilities
    gparted
    gnome-disk-utility

    # Image / PDF viewers
    kdePackages.gwenview
    kdePackages.okular

    # File browser
    xfce.thunar
    xfce.thunar-volman
    xfce.tumbler # thumbnails
  ];

  system.stateVersion = "25.11";
}
