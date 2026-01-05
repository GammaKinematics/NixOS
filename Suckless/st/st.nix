# st terminal configuration
{ config, pkgs, lib, ... }:

let
  appearance = import ./appearance.nix { inherit config lib; };
in
{
  nixpkgs.overlays = [(final: prev: {
    st = prev.st.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ final.harfbuzz ];
      patches = (oldAttrs.patches or []) ++ [
        # Scrollback (ringbuffer + float + mouse)
        (final.fetchurl {
          url = "https://st.suckless.org/patches/scrollback/st-scrollback-ringbuffer-0.9.2.diff";
          sha256 = "1r23q4mi5bkam49ld5c3ccwaa1li7bbjx0ndjgm207p02az9h4cn";
        })
        (final.fetchurl {
          url = "https://st.suckless.org/patches/scrollback/st-scrollback-float-0.9.2.diff";
          sha256 = "01r1gdgkcpf9194257myjnr5nn1fj1baj13wjm9rf2nclbagifgm";
        })
        (final.fetchurl {
          url = "https://st.suckless.org/patches/scrollback/st-scrollback-mouse-0.9.2.diff";
          sha256 = "068s5rjvvw2174y34i5xxvpw4jvjy58akd1kgf025h1153hmf7jy";
        })
        # Alpha (transparency)
        (final.fetchurl {
          url = "https://st.suckless.org/patches/alpha/st-alpha-20240814-a0274bc.diff";
          sha256 = "0hld9dwkk7i1f0z0k9biigx2g4wzlqa2yb7vdn5rrf6ymr5nlbsn";
        })
        # Anysize (no gaps)
        (final.fetchurl {
          url = "https://st.suckless.org/patches/anysize/st-expected-anysize-0.9.diff";
          sha256 = "04gvkf80lhaiwyv3m7fdkf81msf8al1kfb7inx1bf02ygx9152v2";
        })
        # Bold is not bright
        (final.fetchurl {
          url = "https://st.suckless.org/patches/bold-is-not-bright/st-bold-is-not-bright-20190127-3be4cf1.diff";
          sha256 = "1cpap2jz80n90izhq5fdv2cvg29hj6bhhvjxk40zkskwmjn6k49j";
        })
        # Clipboard
        (final.fetchurl {
          url = "https://st.suckless.org/patches/clipboard/st-clipboard-0.8.3.diff";
          sha256 = "1h1nwilwws02h2lnxzmrzr69lyh6pwsym21hvalp9kmbacwy6p0g";
        })
        # Ligatures (scrollback-ringbuffer variant)
        (final.fetchurl {
          url = "https://st.suckless.org/patches/ligatures/0.9.3/st-ligatures-scrollback-ringbuffer-20251007-0.9.3.diff";
          sha256 = "0c2w1p0siafiyarfx6skdighwzw29d1mydpjfrwgrvdsywwyq2di";
        })
      ];
      postPatch = (oldAttrs.postPatch or "") + ''
        # Font
        substituteInPlace config.def.h \
          --replace '"Liberation Mono:pixelsize=12:antialias=true:autohint=true"' \
                    '"${appearance.font}"'

        # Alpha
        substituteInPlace config.def.h \
          --replace 'float alpha = 0.8;' \
                    'float alpha = ${appearance.alpha};'

        # Colors
        ${appearance.colorsSed}
      '';
    });
  })];

  environment.systemPackages = [ pkgs.st ];
}
