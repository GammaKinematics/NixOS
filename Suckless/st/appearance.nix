# st appearance settings
{ config, lib }:

let
  colors = config.lib.stylix.colors;
  fonts = config.stylix.fonts;
in
{
  font = "${fonts.monospace.name}:pixelsize=${toString (fonts.sizes.terminal + 2)}:antialias=true:autohint=true";
  alpha = "0.9";

  colorsSed = ''
    sed -i '/static const char \*colorname\[\]/,/^};/c\
static const char *colorname[] = {\
	/* 8 normal colors */\
	"#${colors.base00}",\
	"#${colors.base08}",\
	"#${colors.base0B}",\
	"#${colors.base0A}",\
	"#${colors.base0D}",\
	"#${colors.base0E}",\
	"#${colors.base0C}",\
	"#${colors.base05}",\
\
	/* 8 bright colors */\
	"#${colors.base03}",\
	"#${colors.base08}",\
	"#${colors.base0B}",\
	"#${colors.base0A}",\
	"#${colors.base0D}",\
	"#${colors.base0E}",\
	"#${colors.base0C}",\
	"#${colors.base07}",\
\
	[255] = 0,\
\
	/* more colors can be added after 255 to use with DefaultXX */\
	"#${colors.base04}",  /* 256: cursor */\
	"#${colors.base03}",  /* 257: reverse cursor */\
	"#${colors.base05}",  /* 258: foreground */\
	"#${colors.base00}",  /* 259: background */\
};' config.def.h
  '';
}
