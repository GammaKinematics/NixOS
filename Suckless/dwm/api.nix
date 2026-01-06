# dwm fifo API - control dwm via named pipe
# Usage: echo "command" > /tmp/dwm.fifo
{ lib }:

{
  config = ''
    /* dwmfifo - control dwm via named pipe */
    static const char *dwmfifo = "/tmp/dwm.fifo";
    static Command commands[] = {
    	/* standard commands */
    	{ "term",            spawn,          {.v = termcmd} },
    	{ "quit",            quit,           {0} },
    	{ "focusstack",      focusstack,     .parse = parseplusminus },
    	{ "incnmaster",      incnmaster,     .parse = parseplusminus },
    	{ "setmfact",        setmfact,       .parse = parseplusminus },
    	{ "zoom",            zoom,           {0} },
    	{ "killclient",      killclient,     {0} },
    	{ "setlayout-tiled", setlayout,      {.v = &layouts[0]} },
    	{ "setlayout-float", setlayout,      {.v = &layouts[1]} },
    	{ "setlayout-mono",  setlayout,      {.v = &layouts[2]} },
    	{ "togglelayout",    setlayout,      {0} },
    	{ "togglefloating",  togglefloating, {0} },
    	{ "viewwin",         viewwin,        .parse = parsexid },
    	{ "viewname",        viewname,       .parse = parsestr },
    	{ "viewall",         view,           {.ui = ~0} },
    	{ "focusmon",        focusmon,       .parse = parseplusminus },
    	{ "tagmon",          tagmon,         .parse = parseplusminus },
    	{ "view",            view,           .parse = parsetag },
    	{ "toggleview",      toggleview,     .parse = parsetag },
    	{ "tag",             tag,            .parse = parsetag },
    	{ "toggletag",       toggletag,      .parse = parsetag },
    	/* monitor targeting for scripts */
    	{ "nthmon0",         focusnthmon,    {.i = 0} },
    	{ "nthmon1",         focusnthmon,    {.i = 1} },
    	{ "sendnthmon0",     tagnthmon,      {.i = 0} },
    	{ "sendnthmon1",     tagnthmon,      {.i = 1} },
    	/* app spawns */
    	{ "rofi",            spawn,          {.v = roficmd} },
    	{ "browser",         spawn,          {.v = browsercmd} },
    	{ "files",           spawn,          {.v = filescmd} },
    	{ "editor",          spawn,          {.v = editorcmd} },
    	/* kicad workflow - tag 16= sch/pcb, tag 17= pm */
    	{ "kicad-sch",       view,           {.ui = 1 << 15} },
    	{ "kicad-pcb",       view,           {.ui = 1 << 15} },
    	{ "kicad-all",       view,           {.ui = 1 << 15} },
    	{ "kicad-pm",        view,           {.ui = 1 << 16} },
    };
  '';
}
