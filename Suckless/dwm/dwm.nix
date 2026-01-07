# dwm window manager configuration
#
# =============================================================================
# Patch Development Notes
# =============================================================================
#
# Base: dwm 6.6 (matches nixpkgs)
# Clone: ~/NixOS/dwm
#
# Clean & Build Commands:
#   cd ~/NixOS/dwm
#   git reset --hard 6.6
#   rm -f config.h drw.o dwm dwm.o util.o
#   nix-shell -p xorg.libX11 xorg.libXft xorg.libXinerama xorg.libXcursor pkg-config gnumake gcc
#   make clean && make
#
# Generate patch after all patches applied:
#   git diff 6.6 > ~/NixOS/Suckless/dwm/dwm-lebowski.patch
#
# =============================================================================
# Patches (apply in order):
# =============================================================================
#
#  1. pertag           - Per-tag layouts (applied separately, then tab)
#  2. tab              - Tabbed monocle bar
#  3. fullgaps         - Simple gaps between windows
#  4. holdbar-modkey   - Show bar while holding mod key
#  5. hide_vacant_tags - Only show occupied tags
#  6. bardwmlogo       - DWM logo in bar
#  7. cursorwarp       - Cursor follows focus
#  8. alwayscenter     - Float windows spawn centered
#  9. swapmonitors     - Swap tagsets between monitors
# 10. adjacenttag      - Navigate tags with arrows (skipvacant)
# 11. accessnthmonitor - Focus/send to specific monitor by number
# 12. dwmfifo          - Control dwm via named pipe
# 13. xcursor          - Use system Xcursor theme (Stylix)
#
# Custom additions:
#   - def_layouts array for per-tag default layouts
#
# =============================================================================

{ config, pkgs, lib, ... }:

let
  appearance = import ./appearance.nix { inherit config lib; };
  tags = import ./tags.nix { inherit lib; };
  rules = import ./rules.nix { inherit lib; };
  layouts = import ./layouts.nix { inherit lib; };
  keybindings = import ./keybindings.nix { inherit lib; };
  api = import ./api.nix { inherit lib; };

  configDefH = ''
${appearance.config}

${tags.config}

${rules.config}

${layouts.config}

${keybindings.config}

${api.config}
  '';
in
{
  services.xserver.windowManager.dwm = {
    enable = true;
    package = (pkgs.dwm.override {
      conf = configDefH;
    }).overrideAttrs (old: {
      patches = [ ./dwm-lebowski.patch ];
      buildInputs = old.buildInputs ++ [ pkgs.xorg.libXcursor ];
    });
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "vieworspawn" ''
      mon=$1; tag=$2; class=$3; shift 3
      # Focus monitor if multi-monitor setup (0=secondary, 1=primary)
      if [[ $(${pkgs.autorandr}/bin/autorandr --current) != "mobile" ]]; then
        [[ "$mon" == "0" ]] && echo "mon-sec" > /tmp/dwm.fifo || echo "mon-prim" > /tmp/dwm.fifo
      fi
      echo "view $tag" > /tmp/dwm.fifo
      sleep 0.02
      if ! ${pkgs.xdotool}/bin/xdotool search --class "$class" >/dev/null 2>&1; then
        exec "$@"
      fi
    '')
  ];
}
