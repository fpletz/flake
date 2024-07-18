{
  lib,
  config,
  pkgs,
  ...
}:
let
  extraPrefs = ''
    pref("ui.systemUsesDarkTheme", 1);
    pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    pref("privacy.webrtc.legacyGlobalIndicator", false);
    pref("media.ffmpeg.vaapi.enabled", true);
    pref("gfx.webrender.enabled", true);
    pref("gfx.webrender.all", true);
    pref("gfx.webrender.compositor", true);
    pref("gfx.webrender.compositor.force-enabled", true);
    pref("network.dns.echconfig.enabled", true);
    pref("network.dns.http3_echconfig.enabled", true);
    pref("geo.enabled", false);
    pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
    pref("browser.compactmode.show", true);
  '';
  nativeMessagingHosts = with pkgs; [ tridactyl-native ];
in
{
  options.bpletza.workstation.browser = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.sway;
  };

  config = lib.mkIf config.bpletza.workstation.browser {
    programs.browserpass.enable = true;

    home.sessionVariables = {
      BROWSER = "librewolf";
      DEFAULT_BROWSER = "librewolf";
      MOZ_USE_XINPUT2 = "1";
      MOZ_DBUS_REMOTE = "1";
    };

    xdg.mimeApps = {
      defaultApplications = lib.genAttrs [
        "application/x-extension-htm"
        "application/x-extension-html"
        "application/x-extension-shtml"
        "application/xhtml+xml"
        "application/x-extension-xhtml"
        "application/x-extension-xht"
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ] (_: "librewolf.desktop");
    };

    programs.librewolf = {
      enable = true;
      package = pkgs.librewolf-wayland.override (_attrs: {
        extraPrefs =
          ''
            pref("webgl.disabled", false);
            pref("privacy.resistFingerprinting", false);
          ''
          + extraPrefs;
        inherit nativeMessagingHosts;
      });
    };

    programs.firefox = {
      enable = lib.mkDefault false;
      package = pkgs.firefox.override (_: {
        inherit extraPrefs;
      });
      inherit nativeMessagingHosts;
    };

    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [
        "--enable-features=WebRTCPipeWireCapturer,VaapiVideoDecoder"
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
        "--disable-background-networking"
        "--enable-accelerated-video-decode"
        "--enable-zero-copy"
        "--no-default-browser-check"
        "--disable-sync"
        "--disable-features=MediaRouter"
        "--enable-features=UseOzonePlatform"
      ];
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
        "pgdnlhfefecpicbbihgmbmffkjpaplco" # ublock extra
        "naepdomgkenhinolocfifgehidddafch" # browserpass
      ];
    };

    programs.qutebrowser = {
      enable = true;
      keyBindings = {
        normal = {
          ",v" = "spawn mpv {url}";
          ",V" = "hint links spawn mpv {hint-url}";
        };
      };
      quickmarks = {
        nixpkgs = "https://github.com/NixOS/nixpkgs";
      };
      searchEngines = {
        DEFAULT = "https://www.startpage.com/sp/search?query={}";
        no = "https://noogle.dev/q?term={}";
        nw = "https://wiki.nixos.org/index.php?search={}";
        w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
      };
      settings = {
        auto_save = {
          interval = 60000;
        };
        colors = {
          webpage = {
            preferred_color_scheme = "dark";
            darkmode.enabled = true;
          };
        };
        content = {
          dns_prefetch = false;
          cookies.accept = "no-3rdparty";
          geolocation = false;
        };
        fonts = {
          default_family = "Fira Mono";
          web.family = {
            standard = "Inter";
            fixed = "Fira Mono";
            sans_serif = "Inter";
          };
        };
        url = {
          default_page = "about:blank";
          start_pages = "about:blank";
        };
      };
    };
  };
}
