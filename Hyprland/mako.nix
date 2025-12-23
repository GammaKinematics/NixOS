# Mako - Notification daemon configuration
{ ... }:

{
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      # border-radius = 10;
      # background-color = "#1e1e2e";
      # text-color = "#cdd6f4";
      # border-color = "#89b4fa";
      # border-size = 2;
      # font = "JetBrains Mono 10";
      # width = 300;
      # height = 100;
    };
  };
}
