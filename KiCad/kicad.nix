# KiCad configuration and scripts
# Works with both Hyprland (Wayland) and dwm (X11)
{ pkgs-unstable, pkgs, ... }:

let
  scriptsDir = ./Scripts;
in
{
  home.packages = with pkgs-unstable; [
    kicad

    # Custom scripts
    (pkgs.writeShellScriptBin "kicad-launch" (builtins.readFile "${scriptsDir}/kicad-launch.sh"))
    (pkgs.writeShellScriptBin "kicad-projects" (builtins.readFile "${scriptsDir}/kicad-projects.sh"))
    (pkgs.writeShellScriptBin "kicad-swap" (builtins.readFile "${scriptsDir}/kicad-swap.sh"))
    (pkgs.writeShellScriptBin "kicad-cycle" (builtins.readFile "${scriptsDir}/kicad-cycle.sh"))
    (pkgs.writeShellScriptBin "kicad-lib-launch" (builtins.readFile "${scriptsDir}/kicad-lib-launch.sh"))
  ];
}
