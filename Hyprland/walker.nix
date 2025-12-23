{ config, inputs, ... }:

{
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  programs.walker = {
    enable = true;
    runAsService = true;  # Auto-start walker service

    config = {
      # Search placeholder
      placeholder = "Search...";

      # Enable built-in modules
      modules = [
        { name = "applications"; }
        { name = "runner"; }
        { name = "websearch"; }
        { name = "calc"; }
        # { name = "clipboard"; }  # Requires cliphist
        # { name = "files"; }
        # { name = "symbols"; }
      ];

      # Keybinds for quick selection
      # keybinds = {
      #   quick_activate = ["F1" "F2" "F3" "F4" "F5"];
      # };

      # Web search engines
      # websearch = {
      #   engines = [
      #     { name = "Google"; url = "https://www.google.com/search?q=%s"; }
      #     { name = "DuckDuckGo"; url = "https://duckduckgo.com/?q=%s"; }
      #     { name = "Nix Packages"; url = "https://search.nixos.org/packages?query=%s"; }
      #   ];
      # };
    };

    # Theme configuration
    # style = ''
    #   * {
    #     font-family: "JetBrains Mono";
    #   }
    # '';
  };
}
