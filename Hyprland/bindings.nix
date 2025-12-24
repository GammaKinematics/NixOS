# Hyprland keybindings configuration
{ config, ... }:

let
  flakeDir = "${config.home.homeDirectory}/NixOS";
in

{
  wayland.windowManager.hyprland.settings = {
    # Variables
    "$mod" = "SUPER";
    "$terminal" = "foot";
    "$menu" = "walker";
    "$browser" = "zen";

    # Keybindings
    bind = [
      # Applications
      "$mod, Z, exec, $terminal"
      "$mod, D, exec, $menu"
      "$mod, B, exec, $browser"
      "$mod, Escape, exec, hyprlock"
      "$mod, C, exec, hyprpicker -a" # Color picker to clipboard
      "$mod CTRL, K, exec, ${flakeDir}/KiCad-Scripts/kicad-launch.sh" # Launch KiCad
      "$mod, K, workspace, 101" # Switch to KiCad workspaces (both monitors)
      "$mod, K, workspace, 102"
      "$mod SHIFT, K, togglespecialworkspace, kicad-pm"
      "$mod ALT, K, exec, ${flakeDir}/KiCad-Scripts/kicad-swap.sh" # Swap SCH/PCB positions
      "$mod, I, exec, ${flakeDir}/KiCad-Scripts/kicad-lib-launch.sh"
      "$mod, bracketright, exec, ${flakeDir}/KiCad-Scripts/kicad-cycle.sh f" # Cycle KiCad projects forward
      "$mod, bracketleft, exec, ${flakeDir}/KiCad-Scripts/kicad-cycle.sh b" # Cycle KiCad projects backward
      "$mod, F, exec, env QT_QPA_PLATFORM=xcb FreeCAD --single-instance"

      # Window management
      "$mod, Q, killactive"
      "$mod, W, fullscreen"
      "$mod, R, togglefloating"
      "$mod, P, pseudo"
      "$mod, E, togglesplit"

      # Focus movement
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # Workspace switching
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"

      # Move window to workspace
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"

      # Special workspace (scratchpad)
      "$mod, S, togglespecialworkspace, magic"
      "$mod SHIFT, S, movetoworkspace, special:magic"

      # Exit Hyprland
      "$mod SHIFT, E, exit"

      # Scroll through workspaces on current monitor (vertical model)
      "$mod, mouse_down, workspace, m-1"
      "$mod, mouse_up, workspace, m+1"

      # Keyboard workspace navigation (up/down)
      "$mod CTRL, up, workspace, m-1"
      "$mod CTRL, down, workspace, m+1"
      "$mod CTRL SHIFT, up, movetoworkspace, m-1"
      "$mod CTRL SHIFT, down, movetoworkspace, m+1"

      # Clipboard history (SUPER+V)
      "$mod SHIFT, V, exec, cliphist list | walker --dmenu | cliphist decode | wl-copy"

      # Screenshot bindings (saves to ~/Pictures/Screenshots/)
      ", Print, exec, mkdir -p ~/Pictures/Screenshots && grimblast --notify copysave area ~/Pictures/Screenshots/$(date +%F_%T).png"
      "SHIFT, Print, exec, mkdir -p ~/Pictures/Screenshots && grimblast --notify copysave output ~/Pictures/Screenshots/$(date +%F_%T).png"
      "CTRL, Print, exec, grimblast --notify save area - | swappy -f -"

      # Control center (quickshell)
      "$mod, X, exec, quickshell -c control-center"

      # On-screen keyboard toggle (for tablet mode)
      # "$mod, K, exec, pkill wvkbd-mobintl || wvkbd-mobintl"
    ];

    # Mouse bindings
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # Repeat bindings (hold key for continuous action)
    binde = [
      "$mod ALT, left, resizeactive, -20 0"
      "$mod ALT, right, resizeactive, 20 0"
      "$mod ALT, up, resizeactive, 0 -20"
      "$mod ALT, down, resizeactive, 0 20"
    ];

    # Media/hardware key bindings (bindl = works even when locked)
    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];

    # Volume keys with repeat (binde = repeat when held)
    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];
  };
}
