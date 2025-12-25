{
  config,
  pkgs-unstable,
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
    ./Hyprland/hyprland.nix
  ];

  home.username = "lebowski";
  home.homeDirectory = "/home/lebowski";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # ============================================================================
  # User Packages (from unstable)
  # ============================================================================
  home.packages = with pkgs-unstable; [
    # Media & Creative
    haruna
    krita
    xournalpp

    # Office & Productivity
    libreoffice-fresh
    keepassxc

    # CLI tools
    bat
    neofetch
    jq # JSON processor (used by power-tuning script)

    # Dev tools
    claude-code
  ];

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
  programs.bash.enable = true;

  programs.foot = {
    enable = true;
    package = pkgs-unstable.foot;
  };

  # ============================================================================
  # Disable version check - we intentionally use unstable home-manager with stable nixpkgs
  # Note: This may cause issues if home-manager uses features not yet in stable
  home.enableNixpkgsReleaseCheck = false;

  home.stateVersion = "25.11";
}
