{
  config,
  pkgs-unstable,
  pkgs-stable,
  inputs,
  ...
}:

let
  flakeDir = "${config.home.homeDirectory}/NixOS";
in

{
  imports = [
    ./git.nix
    ./zed.nix
    ./zen.nix
    ./axium.nix
    ./Rofi/rofi.nix
    ./KiCad/kicad.nix
    # ./Hyprsuck/home.nix
    ./Suckless/home.nix # Uncomment for dwm (and comment Hyprsuck)
  ];

  home.username = "lebowski";
  home.homeDirectory = "/home/lebowski";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # ============================================================================
  # User Packages (stable by default, unstable for bleeding-edge tools)
  # ============================================================================
  home.packages = with pkgs-stable; [
    # Media & Creative
    haruna
    krita
    xournalpp

    # Office & Productivity
    libreoffice-fresh

    # CAD & Manufacturing
    freecad
    bambu-studio

    # Dev tools (unstable for latest features)
    pkgs-unstable.claude-code
    pkgs-unstable.hcloud
  ];

  # ============================================================================
  # GTK Icon Theme
  # ============================================================================
  gtk.iconTheme = {
    package = pkgs-stable.papirus-icon-theme;
    name = "Papirus-Dark";
  };

  # ============================================================================
  # Notifications (shared between Hyprland and dwm)
  # ============================================================================
  services.dunst = {
    enable = true;
    package = pkgs-stable.dunst;
    settings.global.timeout = 3;
  };

  # ============================================================================
  # Shell Aliases
  # ============================================================================
  home.shellAliases = {
    # NixOS rebuild shortcuts
    nrs = "sudo nixos-rebuild switch --flake ${flakeDir}";
    nrb = "sudo nixos-rebuild boot --flake ${flakeDir}";
    nrt = "sudo nixos-rebuild test --flake ${flakeDir}";

    # Nix utilities
    nfu = "nix flake update --flake ${flakeDir}";
    ncg = "sudo nix-collect-garbage -d";
    nso = "nix store optimise";
  };

  # ============================================================================
  # Optional: Additional program configurations
  # ============================================================================

  # --- Bash shell ---
  programs.bash = {
    enable = true;
    package = pkgs-stable.bash;
  };

  # --- KeePassXC ---
  programs.keepassxc = {
    enable = true;
    package = pkgs-stable.keepassxc;
  };

  # --- Chromium (ungoogled) ---
  # programs.chromium = {
  #   enable = true;
  #   package = pkgs-unstable.ungoogled-chromium;
  #   extensions = [
  #     { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }  # uBlock Origin
  #   ];
  # };

  # ============================================================================
  # Disable version check - we intentionally use unstable home-manager with stable nixpkgs
  # Note: This may cause issues if home-manager uses features not yet in stable
  home.enableNixpkgsReleaseCheck = false;

  home.stateVersion = "25.11";
}
