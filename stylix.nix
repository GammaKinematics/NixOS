{ pkgs, ... }:

{
  stylix = {
    enable = true;
    enableReleaseChecks = false;

    polarity = "dark";

    # Catppuccin Mocha theme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Wallpaper (used for color scheme generation)
    image = ./Wallpapers/siege.png;

    # Cursor
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 20;
    };

    # Fonts
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 11;
        applications = 11;
        desktop = 11;
      };
    };

    # Opacity settings
    opacity = {
      terminal = 0.9;
    };
  };
}
