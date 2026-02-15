# dwm window rules
# Tag mapping: 1<<9=term, 1<<10=files, 1<<11=video, 1<<12=web, 1<<13=code,
#              1<<14=freecad, 1<<15=kicad-pm, 1<<16=kicad, 1<<17=kicad-aux
{ lib }:

{
  config = ''
    static const Rule rules[] = {
    	/* xprop(1):
    	 *	WM_CLASS(STRING) = instance, class
    	 *	WM_NAME(STRING) = title
    	 */
    	/* class              instance    title                 tags mask     isfloating  monitor */
    	{ "Polkit-gnome-authentication-agent-1", NULL, NULL,    0,            1,           -1 },
    	{ "KeePassXC",        NULL,       NULL,                 0,            1,           -1 },
    	{ NULL,               NULL,       "Picture-in-Picture", 0,            1,           -1 },
      { "slint-viewer",     NULL,       NULL,                 0,            1,           -1 },
      { "LVGL Simulator",   NULL,       NULL,                 0,            1,           -1 },
      { NULL,               NULL,       "Axium Browser",      0,            1,           -1 },
      { NULL,               NULL,       "Axium",              0,            1,           -1 },
      { NULL,               NULL,       "Fex",                0,            1,           -1 },
      { NULL,               NULL,       "@",                  0,            1,           -1 },
      { NULL,               NULL,       "OSM",                0,            1,           -1 },
    	{ "st-256color",      NULL,       NULL,                 1 << 9,       0,            0 },  /* terminal */
    	{ "Thunar",           NULL,       NULL,                 1 << 10,      0,            0 },  /* files */
    	{ "haruna",           NULL,       NULL,                 1 << 11,      0,            1 },  /* video */
    	{ "zen-twilight",     NULL,       "Zen Twilight",       1 << 12,      0,            1 },  /* web */
    	{ "dev.zed.Zed",      NULL,       NULL,                 1 << 13,      0,            1 },  /* code */
    	{ "FreeCAD",          NULL,       "Expression editor",  0,            1,           -1 },  /* freecad formula popup */
    	{ "FreeCAD",          NULL,       "Insert length",      0,            1,           -1 },  /* freecad dimension popup */
    	{ "FreeCAD",          NULL,       NULL,                 1 << 14,      0,            1 },  /* freecad */
      { "KiCad",            NULL,       "KiCad 9",            1 << 15,      0,            0 },  /* kicad-pm: tag 16 */
    	{ "KiCad",            NULL,       "Schematic Editor",   1 << 16,      0,            0 },  /* kicad: tag 17, mon 0 */
    	{ "KiCad",            NULL,       "Symbol Editor",      1 << 16,      0,            0 },  /* kicad: tag 17, mon 0 */
    	{ "KiCad",            NULL,       "PCB Editor",         1 << 16,      0,            1 },  /* kicad: tag 17, mon 1 */
    	{ "KiCad",            NULL,       "Footprint Editor",   1 << 16,      0,            1 },  /* kicad: tag 17, mon 1 */
      { "BambuStudio",      NULL,       NULL,                 1 << 18,      0,            1 },  /* bambu studio */
    };
  '';
}
