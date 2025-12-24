# Mako - Notification daemon configuration
{ pkgs-unstable, ... }:

{
  services.mako = {
    enable = true;
    package = pkgs-unstable.mako;
    settings = {
      default-timeout = 3000;
    };
  };
}
