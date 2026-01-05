# dwm appearance settings (colors, fonts, borders, gaps)
# Integrates with Stylix for consistent theming
{ config, lib }:

let
  colors = config.lib.stylix.colors;
  fonts = config.stylix.fonts;
in
{
  config = ''
    /* See LICENSE file for copyright and license details. */

    /* appearance */
    static const unsigned int borderpx  = 2;        /* border pixel of windows */
    static const unsigned int gappx     = 5;        /* gaps between windows */
    static const unsigned int snap      = 32;       /* snap pixel */
    static const int showbar            = 0;        /* 0 means no bar (holdbar shows on key hold) */
    static const int topbar             = 1;        /* 0 means bottom bar */
    /*  Display modes of the tab bar: never shown, always shown, shown only in  */
    /*  monocle mode in the presence of several windows.                        */
    /*  Modes after showtab_nmodes are disabled.                                */
    enum showtab_modes { showtab_never, showtab_auto, showtab_nmodes, showtab_always};
    static const int showtab			= showtab_auto;        /* Default tab bar show mode */
    static const int toptab				= False;               /* False means bottom tab bar */

    static const char *fonts[]          = { "${fonts.monospace.name}:size=${toString fonts.sizes.terminal}" };
    static const char dmenufont[]       = "${fonts.monospace.name}:size=${toString fonts.sizes.terminal}";
    static const char col_gray1[]       = "#${colors.base00}";
    static const char col_gray2[]       = "#${colors.base01}";
    static const char col_gray3[]       = "#${colors.base04}";
    static const char col_gray4[]       = "#${colors.base05}";
    static const char col_cyan[]        = "#${colors.base0D}";
    static const char *colors[][3]      = {
    	/*               fg         bg         border   */
    	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
    	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
    };
  '';
}
