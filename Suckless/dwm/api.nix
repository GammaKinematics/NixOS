# dwm fifo API - control dwm via named pipe
# Usage: echo "command" > /tmp/dwm.fifo
{ lib }:

{
  config = ''
    /* dwmfifo - control dwm via named pipe */
    static const char *dwmfifo = "/tmp/dwm.fifo";
    static Command commands[] = {
    	/* ═══════════════════════════════════════════════════════════════════════
    	 * TAG NAVIGATION - Semantic names matching workflow
    	 * ═══════════════════════════════════════════════════════════════════════ */
    	{ "view",           view,           .parse = parsetag },      /* Generic: view 5 */
    	{ "view-all",       view,           {.ui = ~0} },             /* All tags */
    	{ "view-prev",      viewprev,       {0} },                    /* Previous tag */
    	{ "view-next",      viewnext,       {0} },                    /* Next tag */

    	/* Semantic tag shortcuts (matching tags.nix) */
    	{ "terminal",       view,           {.ui = 1 << 9} },         /* Tag 10: */
    	{ "files",          view,           {.ui = 1 << 10} },        /* Tag 11: */
    	{ "video",          view,           {.ui = 1 << 11} },        /* Tag 12: */
    	{ "browser",        view,           {.ui = 1 << 12} },        /* Tag 13: 󰖟 */
    	{ "code",           view,           {.ui = 1 << 13} },        /* Tag 14: */
    	{ "freecad",        view,           {.ui = 1 << 14} },        /* Tag 15: 󰻬 */
    	{ "kicad",          view,           {.ui = 1 << 15} },        /* Tag 16: (sch/pcb) */
    	{ "kicad-pm",       view,           {.ui = 1 << 16} },        /* Tag 17: (project manager) */

    	/* ═══════════════════════════════════════════════════════════════════════
    	 * MONITOR CONTROL - Primary (left) / Secondary (right)
    	 * ═══════════════════════════════════════════════════════════════════════ */
    	{ "mon-prim",       focusnthmon,    {.i = 1} },               /* Focus primary monitor */
    	{ "mon-sec",        focusnthmon,    {.i = 0} },               /* Focus secondary monitor */
    	{ "mon-send-prim",  tagnthmon,      {.i = 1} },               /* Send window to primary */
    	{ "mon-send-sec",   tagnthmon,      {.i = 0} },               /* Send window to secondary */
    	{ "mon-swap",       swapmon,        {0} },                    /* Swap monitor contents */

    	/* ═══════════════════════════════════════════════════════════════════════
    	 * WINDOW MANAGEMENT
    	 * ═══════════════════════════════════════════════════════════════════════ */
    	{ "focus-next",     focusstack,     {.i = +1} },              /* Next window in stack */
    	{ "focus-prev",     focusstack,     {.i = -1} },              /* Previous window */
    	{ "focus",          focusstack,     .parse = parseplusminus },/* Generic: focus +2 */
    	{ "kill",           killclient,     {0} },                    /* Close window */
    	{ "zoom",           zoom,           {0} },                    /* Promote to master */
    	{ "float",          togglefloating, {0} },                    /* Toggle floating */

    	/* ═══════════════════════════════════════════════════════════════════════
    	 * LAYOUT
    	 * ═══════════════════════════════════════════════════════════════════════ */
    	{ "layout-tile",    setlayout,      {.v = &layouts[0]} },
    	{ "layout-float",   setlayout,      {.v = &layouts[1]} },
    	{ "layout-mono",    setlayout,      {.v = &layouts[2]} },
    	{ "layout-toggle",  setlayout,      {0} },                    /* Cycle layouts */

    	/* ═══════════════════════════════════════════════════════════════════════
    	 * MASTER AREA
    	 * ═══════════════════════════════════════════════════════════════════════ */
    	{ "master-inc",     incnmaster,     {.i = +1} },
    	{ "master-dec",     incnmaster,     {.i = -1} },
    	{ "mfact",          setmfact,       .parse = parseplusminus },/* mfact +0.05 */

    	/* ═══════════════════════════════════════════════════════════════════════
    	 * TAG MANAGEMENT
    	 * ═══════════════════════════════════════════════════════════════════════ */
    	{ "toggleview",     toggleview,     .parse = parsetag },
    	{ "tag",            tag,            .parse = parsetag },
    	{ "toggletag",      toggletag,      .parse = parsetag },
    	{ "tagmon",         tagmon,         .parse = parseplusminus },

    	/* ═══════════════════════════════════════════════════════════════════════
    	 * ADVANCED (window targeting)
    	 * ═══════════════════════════════════════════════════════════════════════ */
    	{ "viewwin",        viewwin,        .parse = parsexid },      /* Focus by X window ID */
    	{ "viewname",       viewname,       .parse = parsestr },      /* Focus by name */

    	/* ═══════════════════════════════════════════════════════════════════════
    	 * SPAWNS
    	 * ═══════════════════════════════════════════════════════════════════════ */
    	{ "spawn-term",     spawn,          {.v = termcmd} },
    	{ "spawn-browser",  spawn,          {.v = browsercmd} },
    	{ "spawn-rofi",     spawn,          {.v = roficmd} },
    	{ "spawn-files",    spawn,          {.v = filescmd} },
    	{ "spawn-editor",   spawn,          {.v = editorcmd} },

    	/* ═══════════════════════════════════════════════════════════════════════
    	 * SESSION
    	 * ═══════════════════════════════════════════════════════════════════════ */
    	{ "quit",           quit,           {0} },
    };
  '';
}
