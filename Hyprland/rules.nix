# Hyprland window rules and workspace configuration
{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Window rules (old syntax for Hyprland 0.52.1)
    windowrule = [
      "float, class:^(pavucontrol)$"
      "float, class:^(org.keepassxc.KeePassXC)$"
      "float, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"

      # KiCad window management (regex must fully match since v0.46.0)
      # Project Manager - script handles moving to scratchpad after editors open

      # Schematic/Symbol Editor → workspace 102 (eDP-1), maximized, grouped
      "workspace 102 silent, class:^(KiCad|kicad)$, title:.*Schematic Editor.*"
      "maximize, class:^(KiCad|kicad)$, title:.*Schematic Editor.*"
      "group set, class:^(KiCad|kicad)$, title:.*Schematic Editor.*"
      "workspace 102 silent, class:^(KiCad|kicad)$, title:.*Symbol Editor.*"
      "maximize, class:^(KiCad|kicad)$, title:.*Symbol Editor.*"
      "group set, class:^(KiCad|kicad)$, title:.*Symbol Editor.*"

      # PCB/Footprint Editor → workspace 101 (DP-3), maximized, grouped
      "workspace 101 silent, class:^(KiCad|kicad)$, title:.*PCB Editor.*"
      "maximize, class:^(KiCad|kicad)$, title:.*PCB Editor.*"
      "group set, class:^(KiCad|kicad)$, title:.*PCB Editor.*"
      "workspace 101 silent, class:^(KiCad|kicad)$, title:.*Footprint Editor.*"
      "maximize, class:^(KiCad|kicad)$, title:.*Footprint Editor.*"
      "group set, class:^(KiCad|kicad)$, title:.*Footprint Editor.*"
    ];

    # Workspace rules
    workspace = [
      "101, monitor:DP-3, defaultName:kicad_prim"
      "102, monitor:eDP-1, defaultName:kicad_sec"
    ];
  };
}
