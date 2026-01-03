# slstatus - suckless status bar
{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.slstatus.overrideAttrs (old: {
      postPatch = ''
        cat > config.h << 'EOF'
/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 256

static const struct arg args[] = {
	/* function        format          argument */
	{ battery_perc,    "BAT %s%% | ",  "BAT0" },
	{ datetime,        "%s",           "%a %b %d %H:%M" },
};
EOF
      '';
    }))
  ];
}
