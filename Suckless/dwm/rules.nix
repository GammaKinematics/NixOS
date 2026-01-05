# dwm window rules
# Tag mapping: 1<<9=term, 1<<10=files, 1<<11=video, 1<<12=web, 1<<13=code,
#              1<<14=freecad, 1<<15=kicad sch/pcb, 1<<16=kicad pm
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
    	{ "st-256color",      NULL,       NULL,                 1 << 9,       0,            0 },  /* terminal */
    	{ "Thunar",           NULL,       NULL,                 1 << 10,      0,            0 },  /* files */
    	{ "haruna",           NULL,       NULL,                 1 << 11,      0,            1 },  /* video */
    	{ "zen-twilight",     NULL,       NULL,                 1 << 12,      0,            1 },  /* web */
    	{ "dev.zed.Zed",      NULL,       NULL,                 1 << 13,      0,            1 },  /* code */
    	{ "FreeCAD",          NULL,       NULL,                 1 << 14,      0,            1 },  /* freecad */
    	{ "KiCad",            NULL,       "Schematic Editor",   1 << 15,      0,            0 },  /* kicad sch/pcb */
    	{ "KiCad",            NULL,       "Symbol Editor",      1 << 15,      0,            0 },  /* kicad sch/pcb */
    	{ "KiCad",            NULL,       "PCB Editor",         1 << 15,      0,            1 },  /* kicad sch/pcb */
    	{ "KiCad",            NULL,       "Footprint Editor",   1 << 15,      0,            1 },  /* kicad sch/pcb */
    	{ "Kicad",            NULL,       NULL,                 1 << 16,      0,            0 },  /* kicad pm */
    };
  '';
}
