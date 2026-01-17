{ config, pkgs-unstable, inputs, ... }:

{
  # Tell Stylix which Zen profiles to theme
  stylix.targets.zen-browser.profileNames = [ "default" ];

  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  # Set Zen as default browser for all relevant MIME types
  xdg.mimeApps = let
    associations = builtins.listToAttrs (map (name: {
        inherit name;
        value = let
          zen-browser = config.programs.zen-browser.package;
        in
          zen-browser.meta.desktopFileName;
      }) [
        "application/x-extension-shtml"
        "application/x-extension-xhtml"
        "application/x-extension-html"
        "application/x-extension-xht"
        "application/x-extension-htm"
        "x-scheme-handler/unknown"
        "x-scheme-handler/mailto"
        "x-scheme-handler/chrome"
        "x-scheme-handler/about"
        "x-scheme-handler/https"
        "x-scheme-handler/http"
        "application/xhtml+xml"
        "application/json"
        "text/plain"
        "text/html"
      ]);
  in {
    associations.added = associations;
    defaultApplications = associations;
  };

  programs.zen-browser = {
    enable = true;

    # Native Messaging Hosts - required for KeePassXC browser integration
    nativeMessagingHosts = [ pkgs-unstable.keepassxc ];

    policies = let
      # Helper to lock preferences
      mkLockedAttrs = builtins.mapAttrs (_: value: {
        Value = value;
        Status = "locked";
      });

      # Helper to create extension install URL
      mkPluginUrl = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

      # Helper to create extension entry with options
      mkExtensionEntry = {
        id,
        pinned ? false,
        private_browsing ? true,
      }: let
        base = {
          install_url = mkPluginUrl id;
          installation_mode = "force_installed";
          inherit private_browsing;
        };
      in
        if pinned
        then base // { default_area = "navbar"; }
        else base;

      # Helper to process extension settings
      mkExtensionSettings = builtins.mapAttrs (_: entry:
        if builtins.isAttrs entry
        then entry
        else mkExtensionEntry { id = entry; });
    in {
      # App behavior
      DisableAppUpdate = true;
      DontCheckDefaultBrowser = true;
      DisableFeedbackCommands = true;

      # Privacy & Telemetry
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;

      # Autofill
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      OfferToSaveLogins = false;

      # Tracking Protection
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      # Clean up on shutdown (fresh instance)
      SanitizeOnShutdown = {
        Cache = true;
        Cookies = false;  # Keep logins
        Downloads = true;
        FormData = true;
        History = false;  # Keep history
        Sessions = false;  # Keep tabs on restart
        SiteSettings = false;
        OfflineApps = true;
        Locked = true;
      };

      # Extensions
      ExtensionSettings = mkExtensionSettings {
        # uBlock Origin - ad blocker (pinned to navbar)
        "uBlock0@raymondhill.net" = mkExtensionEntry {
          id = "ublock-origin";
          pinned = true;
          private_browsing = true;
        };
        # KeePassXC - password manager (pinned to navbar)
        "keepassxc-browser@keepassxc.org" = mkExtensionEntry {
          id = "keepassxc-browser";
          pinned = true;
          private_browsing = true;
        };

        # --- Privacy & Security ---
        "{74145f27-f039-47ce-a470-a662b129930a}" = "clearurls";           # Remove tracking from URLs
        "jid1-BoFifL9Vbdl2zQ@jetpack" = "decentraleyes";                  # Local CDN emulation
        "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}" = "chameleon-ext";       # Spoof browser profile

        # --- GitHub ---
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = "refined-github-";     # GitHub enhancements
        "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = "github-file-icons";   # File icons in GitHub
        "github-repository-size@pranavmangal" = "gh-repo-size";           # Show repo size

        # --- YouTube ---
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "return-youtube-dislikes";
      };

      # Locked preferences
      Preferences = mkLockedAttrs {
        "browser.aboutConfig.showWarning" = false;
        "browser.tabs.warnOnClose" = false;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;

        # Translation (auto-translate all languages except en/fr)
        "browser.translations.enable" = true;
        "browser.translations.panelShown" = true;
        "browser.translations.automaticallyPopup" = true;
        "browser.translations.alwaysTranslateLanguages" = "ar,bg,cs,da,de,el,es,et,fi,hu,id,it,ja,ko,lt,lv,nl,no,pl,pt,ro,ru,sk,sl,sv,th,tr,uk,vi,zh";
        "browser.translations.neverTranslateLanguages" = "en,fr";

        # Privacy (balanced - removed slow options)
        "privacy.spoof_english" = 1;
        "network.cookie.cookieBehavior" = 5;
        "dom.battery.enabled" = false;

        # Performance & Speed
        "gfx.webrender.all" = true;
        "layers.acceleration.force-enabled" = true;
        "network.http.http3.enabled" = true;
        "network.dns.disablePrefetch" = false;
        "network.prefetch-next" = true;
        "browser.sessionstore.interval" = 60000;  # Less frequent session saves (60s)
        "browser.cache.memory.enable" = true;
        "browser.cache.memory.capacity" = 524288;  # 512MB memory cache
        "content.notify.interval" = 100000;
        "ui.submenuDelay" = 0;  # Instant submenus

        # Disable animations for snappiness
        "toolkit.cosmeticAnimations.enabled" = false;
        "browser.fullscreen.animate" = false;
      };
    };

    profiles.default = {
      # Zen-specific settings
      settings = {
        "zen.workspaces.continue-where-left-off" = true;  # Restore tabs
        "zen.workspaces.natural-scroll" = true;
        "zen.view.compact.hide-tabbar" = true;
        "zen.view.compact.hide-toolbar" = true;
        "zen.view.compact.animate-sidebar" = false;
        "zen.welcome-screen.seen" = true;
        "zen.urlbar.behavior" = "float";

        # Restore previous session
        "browser.startup.page" = 3;  # Restore previous session
        "browser.sessionstore.resume_from_crash" = true;
      };

      # --- Bookmarks ---
      bookmarks = {
        force = true;
        settings = [
          {
            name = "Dev";
            toolbar = true;
            bookmarks = [
              { name = "GitHub"; url = "https://github.com"; }
              { name = "NixOS Wiki"; url = "https://wiki.nixos.org/"; }
            ];
          }
        ];
      };

      # --- Containers ---
      # containersForce = true;
      # containers = {
      #   Personal = { color = "blue"; icon = "fingerprint"; id = 1; };
      #   Work = { color = "orange"; icon = "briefcase"; id = 2; };
      #   Shopping = { color = "yellow"; icon = "dollar"; id = 3; };
      #   Banking = { color = "green"; icon = "dollar"; id = 4; };
      # };

      # --- Workspaces/Spaces ---
      # spacesForce = true;
      # spaces = {
      #   "Default" = {
      #     id = "generate-your-own-uuid";  # Use: uuidgen
      #     icon = "🏠";
      #     position = 1000;
      #   };
      #   "Work" = {
      #     id = "generate-your-own-uuid";
      #     icon = "💼";
      #     position = 1001;
      #     # container = containers."Work".id;  # Link to container
      #     theme = {
      #       type = "gradient";
      #       colors = [
      #         {
      #           red = 100;
      #           green = 150;
      #           blue = 200;
      #           algorithm = "floating";
      #           type = "explicit-lightness";
      #         }
      #       ];
      #       opacity = 0.5;
      #       texture = 0.3;
      #     };
      #   };
      # };

      # --- Pinned tabs ---
      # pinsForce = true;
      # pins = {
      #   "GitHub" = {
      #     id = "generate-your-own-uuid";
      #     # workspace = spaces."Work".id;
      #     url = "https://github.com";
      #     position = 100;
      #     isEssential = false;
      #   };
      # };

      # --- Search engines ---
      search = {
        force = true;
        default = "google";
        engines = let
          nixIcon = "${pkgs-unstable.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        in {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "channel"; value = "unstable"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = nixIcon;
            definedAliases = [ "np" ];
          };
          "Nix Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "channel"; value = "unstable"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = nixIcon;
            definedAliases = [ "no" ];
          };
          "Home Manager Options" = {
            urls = [{
              template = "https://home-manager-options.extranix.com/";
              params = [
                { name = "query"; value = "{searchTerms}"; }
                { name = "release"; value = "master"; }
              ];
            }];
            icon = nixIcon;
            definedAliases = [ "hm" ];
          };
          # Hide unwanted default engines
          "bing".metaData.hidden = true;
        };
      };
    };
  };
}
