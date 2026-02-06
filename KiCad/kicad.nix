# KiCad configuration and scripts
# Works with both Hyprland (Wayland) and dwm (X11)
{ pkgs-stable, ... }:

let
  scriptsDir = ./Scripts;
in
{
  home.packages = with pkgs-stable; [
    kicad

    # Custom scripts
    (writeShellScriptBin "kicad-launch" (builtins.readFile "${scriptsDir}/kicad-launch.sh"))
    (writeShellScriptBin "kicad-projects" (builtins.readFile "${scriptsDir}/kicad-projects.sh"))
    (writeShellScriptBin "kicad-show" (builtins.readFile "${scriptsDir}/kicad-show.sh"))
    (writeShellScriptBin "kicad-swap" (builtins.readFile "${scriptsDir}/kicad-swap.sh"))
    (writeShellScriptBin "kicad-cycle" (builtins.readFile "${scriptsDir}/kicad-cycle.sh"))
    (writeShellScriptBin "kicad-lib-launch" (builtins.readFile "${scriptsDir}/kicad-lib-launch.sh"))
  ];
}
