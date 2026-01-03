# Hyprland general settings
# Input, appearance, layout, gestures, misc
{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Input configuration
    input = {
      kb_layout = "us";
      numlock_by_default = true;

      follow_mouse = 1;
      sensitivity = 0;

      touchpad = {
        natural_scroll = true;
      };
    };

    # General settings
    general = {
      gaps_in = 5;
      gaps_out = 5;
      border_size = 2;
      layout = "dwindle";
    };

    # Decoration
    decoration = {
      rounding = 10;
      # blur = {
      #   enabled = true;
      #   size = 3;
      #   passes = 1;
      # };
      # shadow = {
      #   enabled = true;
      #   range = 4;
      #   render_power = 3;
      # };
    };

    # Animations
    animations = {
      enabled = true;
      # bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        # "windows, 1, 7, myBezier"
        # "windowsOut, 1, 7, default, popin 80%"
        # "border, 1, 10, default"
        # "fade, 1, 7, default"
        "workspaces, 1, 4, default, slidevert"
      ];
    };

    # Layout settings
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    # Gestures (Hyprland 0.51+ new syntax)
    gestures = {
      workspace_swipe_distance = 500;
      workspace_swipe_invert = false;
      workspace_swipe_create_new = false;
    };

    # New gesture bindings (replaces workspace_swipe)
    # Vertical 3-finger swipe for workspace switching
    gesture = [
      "3, vertical, workspace"
    ];

    # Misc
    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
    };
  };
}
