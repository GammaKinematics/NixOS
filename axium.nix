# Axium Browser - custom ungoogled-chromium + thorium optimizations
# Note: Based on ungoogled-chromium, uses .config/chromium directory
{ inputs, pkgs-unstable, ... }:

let
  axium = inputs.axium.packages.x86_64-linux.default;
in
{
  programs.chromium = {
    enable = true;
    package = axium;

    # Extensions (ID from Chrome Web Store URL)
    extensions = [
      { id = "oboonakemofpalcgghocfoadofidjkkk"; }  # KeePassXC-Browser
      # Add more extensions:
      # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }  # uBlock Origin
    ];

    # Optional: command line args
    # commandLineArgs = [ "--enable-features=VaapiVideoDecoder" ];
  };

  # KeePassXC native messaging host for Axium/Chromium
  home.file.".config/chromium/NativeMessagingHosts/org.keepassxc.keepassxc_browser.json".text = builtins.toJSON {
    name = "org.keepassxc.keepassxc_browser";
    description = "KeePassXC integration with native messaging support";
    path = "${pkgs-unstable.keepassxc}/bin/keepassxc-proxy";
    type = "stdio";
    allowed_origins = [
      "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/"
    ];
  };
}
