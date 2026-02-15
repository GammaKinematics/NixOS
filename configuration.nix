{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./stylix.nix
    # ./Hyprsuck/hyprsuck.nix
    ./Suckless/suckless.nix
    ./ryzenadj.nix
    # ./virtualisation.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Axium binary cache
    substituters = [
      "https://cache.nixos.org"
      "https://axium.cachix.org"
    ];

    http-connections = 128;
    max-substitution-jobs = 128;
    max-jobs = "auto";

    trusted-public-keys = [ "axium.cachix.org-1:BfzPfRTbbCYmaQrVLSWchgsR4ScA9ZCZ389FyWspUH8=" ];
  };

  nix.buildMachines = [{
    hostName = "192.168.2.121";
    sshUser = "lebowski";
    sshKey = "/home/lebowski/.ssh/id_ed25519";
    system = "x86_64-linux";
    maxJobs = 2;
    supportedFeatures = [ "big-parallel" "benchmark" ];
  }];

  nix.distributedBuilds = true;

  # Required for home-manager xdg.portal with useUserPackages
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.timeout = 1;

  networking.hostName = "nixos";

  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;

  time.timeZone = "Asia/Ho_Chi_Minh";
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

  services.getty.autologinUser = "lebowski";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.lebowski = {
    isNormalUser = true;
    description = "Antoine Lespinasse";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
    ];
  };

  # GVfs - for Nautilus trash, network shares, MTP devices
  services.gvfs.enable = true;

  # UPower - battery/power device monitoring
  services.upower.enable = true;

  # Power Profiles Daemon - power management (performance/balanced/power-saver)
  services.power-profiles-daemon.enable = true;

  # System packages (stable for core tools)
  environment.systemPackages = with pkgs; [
    wget
    git
    bat
    btop
    ncdu
    nmap
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
