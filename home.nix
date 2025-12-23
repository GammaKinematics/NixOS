{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  flakeDir,
  ...
}:

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
    kdePackages.gwenview
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
  # Desktop entries for apps that need XWayland
  # ============================================================================
  # xdg.desktopEntries = {
  #   # Custom XWayland-forced entries
  #   kicad-xwayland = {
  #     name = "KiCad";
  #     exec = "env GDK_BACKEND=x11 kicad %f";
  #     icon = "kicad";
  #     comment = "Suite of tools for schematic design and circuit board layout";
  #     genericName = "EDA Suite";
  #     categories = [
  #       "Science"
  #       "Electronics"
  #     ];
  #     mimeType = [ "application/x-kicad-project" ];
  #     startupNotify = false;
  #     settings.StartupWMClass = "kicad";
  #   };
  #   freecad-xwayland = {
  #     name = "FreeCAD";
  #     exec = "env QT_QPA_PLATFORM=xcb FreeCAD --single-instance %F";
  #     icon = "org.freecad.FreeCAD";
  #     comment = "Feature based Parametric Modeler";
  #     genericName = "CAD Application";
  #     categories = [
  #       "Graphics"
  #       "Science"
  #       "Education"
  #       "Engineering"
  #     ];
  #     mimeType = [
  #       "application/x-extension-fcstd"
  #       "model/obj"
  #       "image/vnd.dwg"
  #       "image/vnd.dxf"
  #     ];
  #     startupNotify = true;
  #     settings.StartupWMClass = "FreeCAD";
  #   };
  #   # Hide the original broken entries
  #   kicad = {
  #     name = "KiCad (Native)";
  #     exec = "kicad";
  #     noDisplay = true;
  #   };
  #   "org.freecad.FreeCAD" = {
  #     name = "FreeCAD (Native)";
  #     exec = "FreeCAD";
  #     noDisplay = true;
  #   };
  # };

  # ============================================================================
  # Shell Aliases
  # ============================================================================
  home.shellAliases = {
    # NixOS rebuild shortcuts
    nrs = "sudo nixos-rebuild switch --flake ${flakeDir}";
    nrb = "sudo nixos-rebuild boot --flake ${flakeDir}";
    nrt = "sudo nixos-rebuild test --flake ${flakeDir}";

    # Nix utilities
    nfu = "nix flake update ${flakeDir}";
    ncg = "sudo nix-collect-garbage -d";
  };

  # ============================================================================
  # Optional: Additional program configurations
  # ============================================================================

  # --- Bash shell ---
  programs.bash = {
    enable = true;
    profileExtra = ''
      # Auto-start Hyprland on tty1
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec Hyprland
      fi
    '';
  };

  programs.foot = {
    enable = true;
  };

  # ============================================================================
  # Disable version check - we intentionally use unstable home-manager with stable nixpkgs
  # Note: This may cause issues if home-manager uses features not yet in stable
  home.enableNixpkgsReleaseCheck = false;

  home.stateVersion = "25.11";
}
