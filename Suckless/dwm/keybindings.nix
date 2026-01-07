# dwm keybindings
{ lib }:

{
  config = ''
    /* key definitions */
    #define MODKEY Mod4Mask
    #define TAGKEYS(KEY,TAG) \
    	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
    	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
    	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
    	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },
    #define HOLDKEY 0xffeb // 0 - disable; 0xffe9 - Mod1Mask; 0xffeb - Mod4Mask (Super)

    /* helper for spawning shell commands in the pre dwm-5.0 fashion */
    #define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

    /* commands */
    static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
    static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
    static const char *roficmd[]  = { "rofi", "-show", "system", NULL };
    static const char *rofiwebcmd[] = { "rofi-websearch", NULL };
    static const char *browsercmd[] = { "zen", NULL };
    static const char *lockcmd[] = { "slock", NULL };
    static const char *kicadshowcmd[] = { "kicad-show", NULL };
    static const char *kicadprojectscmd[] = { "kicad-projects", NULL };
    static const char *kicadlibcmd[] = { "kicad-lib-launch", NULL };
    static const char *kicadswapcmd[] = { "kicad-swap", NULL };
    static const char *kicadcyclefcmd[] = { "kicad-cycle", "f", NULL };
    static const char *kicadcyclebcmd[] = { "kicad-cycle", "b", NULL };
    static const char *screenshotcmd[] = { "flameshot", "gui", NULL };
    static const char *screenshotfullcmd[] = { "flameshot", "full", "--path", "/home/lebowski/Pictures/Screenshots", NULL };
    static const char *cliphistcmd[] = { "sh", "-c", "greenclip print | rofi -dmenu -p Clipboard | xclip -selection clipboard", NULL };
    static const char *volmutecmd[] = { "wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle", NULL };
    static const char *micmutecmd[] = { "wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle", NULL };
    static const char *volupcmd[] = { "sh", "-c", "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+", NULL };
    static const char *voldowncmd[] = { "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-", NULL };

    /* vieworspawn: monitor, tag (1-based), class, cmd... */
    static const char *termvos[]    = { "vieworspawn", "0", "10", "st-256color", "st", NULL };
    static const char *filesvos[]   = { "vieworspawn", "0", "11", "Thunar",      "thunar", NULL };
    static const char *editorvos[]  = { "vieworspawn", "1", "14", "dev.zed.Zed", "zeditor", NULL };
    static const char *freecadvos[] = { "vieworspawn", "1", "15", "FreeCAD",     "FreeCAD", "--single-instance", NULL };

    /* fallback spawn commands */
    static const char *termcmd[]    = { "st", NULL };
    static const char *filescmd[]   = { "thunar", NULL };
    static const char *editorcmd[]  = { "zeditor", NULL };
    static const char *freecadcmd[] = { "FreeCAD", "--single-instance", NULL };

    static const Key keys[] = {
    	/* modifier                     key        function        argument */

    	/* Rofi */
    	{ MODKEY,                       XK_space,  spawn,          {.v = roficmd } },
    	{ MODKEY|Mod1Mask,              XK_space,  spawn,          {.v = rofiwebcmd } },

    	/* Terminal */
    	{ MODKEY,                       XK_a,      spawn,          {.v = termvos } },
    	{ MODKEY|ShiftMask,             XK_a,      spawn,          {.v = termcmd } },

    	/* Zed (code) */
    	{ MODKEY,                       XK_z,      spawn,          {.v = editorvos } },
    	{ MODKEY|ShiftMask,             XK_z,      spawn,          {.v = editorcmd } },

    	/* Zen Browser (web) */
    	{ MODKEY,                       XK_x,      view,           {.ui = 1 << 12 } },
    	{ MODKEY|ShiftMask,             XK_x,      spawn,          {.v = browsercmd } },

    	/* Thunar (files) */
    	{ MODKEY,                       XK_n,      spawn,          {.v = filesvos } },
    	{ MODKEY|ShiftMask,             XK_n,      spawn,          {.v = filescmd } },

    	/* Video */
    	{ MODKEY,                       XK_m,      view,           {.ui = 1 << 11 } },

    	/* Lock */
    	{ MODKEY,                       XK_Escape, spawn,          {.v = lockcmd } },

    	/* KiCad */
    	{ MODKEY,                       XK_k,      spawn,          {.v = kicadshowcmd } },
    	{ MODKEY|ShiftMask,             XK_k,      spawn,          {.v = kicadprojectscmd } },
    	{ MODKEY,                       XK_l,      spawn,          {.v = kicadlibcmd } },
    	{ MODKEY|ControlMask,           XK_k,      view,           {.ui = 1 << 16 } },
    	{ MODKEY|Mod1Mask,              XK_k,      spawn,          {.v = kicadswapcmd } },
    	{ MODKEY,                       XK_bracketright, spawn,    {.v = kicadcyclefcmd } },
    	{ MODKEY,                       XK_bracketleft,  spawn,    {.v = kicadcyclebcmd } },

    	/* FreeCAD */
    	{ MODKEY,                       XK_f,      spawn,          {.v = freecadvos } },
    	{ MODKEY|ShiftMask,             XK_f,      spawn,          {.v = freecadcmd } },

    	/* Window management */
    	{ MODKEY,                       XK_q,      killclient,     {0} },
    	{ MODKEY,                       XK_e,      togglefloating, {0} },
    	{ MODKEY,                       XK_t,      tabmode,        {-1} },

    	/* Focus movement - stack */
    	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
    	{ MODKEY|ShiftMask,             XK_j,      focusstack,     {.i = -1 } },

    	/* Adjacent tags - Up/Down */
    	{ MODKEY,                       XK_Up,     viewprev,       {0} },
    	{ MODKEY,                       XK_Down,   viewnext,       {0} },
    	{ MODKEY|ShiftMask,             XK_Up,     tagtoprev,      {0} },
    	{ MODKEY|ShiftMask,             XK_Down,   tagtonext,      {0} },

    	/* Move to monitor */
    	{ MODKEY,                       XK_Left,   focusnthmon,    {.i = 1 } },
    	{ MODKEY,                       XK_Right,  focusnthmon,    {.i = 0 } },
    	{ MODKEY|ShiftMask,             XK_Left,   tagnthmon,      {.i = 1 } },
    	{ MODKEY|ShiftMask,             XK_Right,  tagnthmon,      {.i = 0 } },

    	/* Swap monitors */
    	{ MODKEY|ShiftMask,             XK_apostrophe, swapmon,    {0} },

    	/* Resize master */
    	{ MODKEY|Mod1Mask,              XK_Left,   setmfact,       {.f = -0.05} },
    	{ MODKEY|Mod1Mask,              XK_Right,  setmfact,       {.f = +0.05} },

    	/* Tags */
    	TAGKEYS(                        XK_1,                      0)
    	TAGKEYS(                        XK_2,                      1)
    	TAGKEYS(                        XK_3,                      2)
    	TAGKEYS(                        XK_4,                      3)
    	TAGKEYS(                        XK_5,                      4)
    	TAGKEYS(                        XK_6,                      5)
    	TAGKEYS(                        XK_7,                      6)
    	TAGKEYS(                        XK_8,                      7)
    	TAGKEYS(                        XK_9,                      8)
    	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
    	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },

    	/* Clipboard */
    	{ MODKEY|ShiftMask,             XK_v,      spawn,          {.v = cliphistcmd } },

    	/* Screenshots */
    	{ 0,                            XK_Print,  spawn,          {.v = screenshotcmd } },
    	{ ShiftMask,                    XK_Print,  spawn,          {.v = screenshotfullcmd } },

    	/* Media keys */
    	{ 0,                            XF86XK_AudioMute,         spawn, {.v = volmutecmd } },
    	{ 0,                            XF86XK_AudioMicMute,      spawn, {.v = micmutecmd } },
    	{ 0,                            XF86XK_AudioRaiseVolume,  spawn, {.v = volupcmd } },
    	{ 0,                            XF86XK_AudioLowerVolume,  spawn, {.v = voldowncmd } },

    	/* Holdbar */
    	{ 0,                            HOLDKEY,   holdbar,        {0} },
    };

    /* button definitions */
    /* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
    static const Button buttons[] = {
    	/* click                event mask      button          function        argument */
    	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
    	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
    	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
    	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
    	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
    	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
    	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
    	{ ClkTagBar,            0,              Button1,        view,           {0} },
    	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
    	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
    	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
    	{ ClkTabBar,            0,              Button1,        focuswin,       {0} },
    	/* Scroll through tags with Mod+scroll */
    	{ ClkRootWin,           MODKEY,         Button4,        viewprev,       {0} },
    	{ ClkRootWin,           MODKEY,         Button5,        viewnext,       {0} },
    	{ ClkClientWin,         MODKEY,         Button4,        viewprev,       {0} },
    	{ ClkClientWin,         MODKEY,         Button5,        viewnext,       {0} },
    };
  '';
}
