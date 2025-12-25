{ pkgs, ... }:

let
  scriptsDir = ./Scripts;
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "kicad-launch" (builtins.readFile "${scriptsDir}/kicad-launch.sh"))
    (pkgs.writeShellScriptBin "kicad-projects" (builtins.readFile "${scriptsDir}/kicad-projects.sh"))
    (pkgs.writeShellScriptBin "kicad-cycle" (builtins.readFile "${scriptsDir}/kicad-cycle.sh"))
    (pkgs.writeShellScriptBin "kicad-lib-launch" (builtins.readFile "${scriptsDir}/kicad-lib-launch.sh"))
    (pkgs.writeShellScriptBin "kicad-swap" (builtins.readFile "${scriptsDir}/kicad-swap.sh"))
  ];
}
