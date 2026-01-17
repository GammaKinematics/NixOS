# Thorium Browser - fast Chromium fork
# Note: Declarative extensions don't work with AppImage packages
# Install extensions manually from Chrome Web Store
{ inputs, pkgs-unstable, ... }:

{
  home.packages = [
    inputs.thorium.packages.x86_64-linux.thorium-avx2
  ];

  # KeePassXC native messaging host for Thorium
  home.file.".config/thorium/NativeMessagingHosts/org.keepassxc.keepassxc_browser.json".text = builtins.toJSON {
    name = "org.keepassxc.keepassxc_browser";
    description = "KeePassXC integration with native messaging support";
    path = "${pkgs-unstable.keepassxc}/bin/keepassxc-proxy";
    type = "stdio";
    allowed_origins = [
      "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/"
    ];
  };
}
