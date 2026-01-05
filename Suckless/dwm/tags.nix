# dwm tag names (Nerd Font icons for special workspaces)
{ lib }:

let
  tags = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"
    "" # 10: terminal
    "" # 11: files
    "" # 12: video
    "󰖟" # 13: web/browser
    "" # 14: code
    "󰻬" # 15: freecad
    "" # 16: kicad schematic/pcb
    "" # 17: kicad project manager
  ];
  tagsStr = lib.concatMapStringsSep ", " (t: ''"${t}"'') tags;
in
{
  config = ''
    /* tagging */
    static const char *tags[] = { ${tagsStr} };
  '';
}
