# Hyprland keybindings configuration
{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Variables
    "$mod" = "SUPER";
    "$terminal" = "foot";
    "$browser" = "zen";

    # Keybindings
    bind = [
      # Rofi
      "$mod, Space, exec, rofi -show drun"
      "$mod ALT, Space, exec, rofi-websearch"

      # Foot terminal - go to workspace 50, launch if not running
      "$mod, A, exec, hyprctl dispatch workspace 50; hyprctl clients -j | grep -q foot || $terminal"

      # Zed - go to workspace 60, launch if not running
      "$mod, Z, exec, hyprctl dispatch workspace 60; hyprctl clients -j | grep -q dev.zed.Zed || zeditor"

      # Zen Browser - workspace 70 (DP-3), launch if no browser on that workspace
      "$mod, B, exec, hyprctl dispatch workspace 70; hyprctl clients -j | jq -e '.[] | select(.class == \"zen-twilight\" and .workspace.id == 70)' > /dev/null || hyprctl dispatch exec [workspace 70 silent] -- $browser"
      # Zen Browser - workspace 71 (eDP-1), launch new window if no browser on that workspace
      "$mod ALT, B, exec, hyprctl dispatch workspace 71; hyprctl clients -j | jq -e '.[] | select(.class == \"zen-twilight\" and .workspace.id == 71)' > /dev/null || hyprctl dispatch exec [workspace 71 silent] -- $browser --new-window"

      # Nautilus - go to workspace 80, launch if not running
      "$mod, N, exec, hyprctl dispatch workspace 80; hyprctl clients -j | grep -q org.gnome.Nautilus || nautilus"

      # Haruna - go to workspace 90
      "$mod, M, workspace, 90"

      "$mod, Escape, exec, hyprlock"

      # Switch to KiCad workspaces (both monitors)
      "$mod, K, workspace, 101"
      "$mod, K, workspace, 102"
      # Launch KiCad project selector
      "$mod CTRL, K, exec, kicad-projects"
      # Launch library editors
      "$mod, L, exec, kicad-lib-launch"
      # Show project manager
      "$mod SHIFT, K, togglespecialworkspace, kicad-pm"
      # Swap SCH/PCB positions
      "$mod ALT, K, exec, kicad-swap"
      # Cycle through project instances
      "$mod, bracketright, exec, kicad-cycle f"
      "$mod, bracketleft, exec, kicad-cycle b"

      # FreeCAD - go to workspace 110, launch if not running
      "$mod, F, exec, hyprctl dispatch workspace 110; hyprctl clients -j | grep -q org.freecad.FreeCAD || env QT_QPA_PLATFORM=xcb FreeCAD --single-instance"

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

      # Clipboard history (SUPER+SHIFT+V)
      "$mod SHIFT, V, exec, cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy"

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
