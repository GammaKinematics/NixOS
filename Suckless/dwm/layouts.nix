# dwm layouts
{ lib }:

let
  # Layout indices: 0 = tile, 1 = floating, 2 = monocle
  defLayouts = [
    0 # index 0: all-tags view
    0 # tag 1
    0 # tag 2
    0 # tag 3
    0 # tag 4
    0 # tag 5
    0 # tag 6
    0 # tag 7
    0 # tag 8
    0 # tag 9
    2 # tag 10: terminal
    2 # tag 11: files
    2 # tag 12: video
    2 # tag 13: web/browser
    2 # tag 14: code
    2 # tag 15: freecad
    2 # tag 16: kicad schematic/pcb
    2 # tag 17: kicad project manager
  ];
  defLayoutsStr = lib.concatMapStringsSep ", " toString defLayouts;
in
{
  config = ''
    /* layout(s) */
    static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
    static const int nmaster     = 1;    /* number of clients in master area */
    static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
    static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

    static const Layout layouts[] = {
    	/* symbol     arrange function */
    	{ "[]=",      tile },    /* 0: first entry is default */
    	{ "><>",      NULL },    /* 1: floating */
    	{ "[M]",      monocle }, /* 2: monocle (tabbed) */
    };

    /* default layout per tag */
    /* 0 = tile, 1 = floating, 2 = monocle */
    static int def_layouts[1 + LENGTH(tags)] = { ${defLayoutsStr} };
  '';
}
