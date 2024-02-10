{ lib, pkgs, ... }:
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
  nativeMessagingHosts = with pkgs; [ ff2mpv browserpass tridactyl-native ];
in
{
  programs.browserpass.enable = true;

  home.sessionVariables = {
    BROWSER = "librewolf";
    DEFAULT_BROWSER = "librewolf";
    MOZ_USE_XINPUT2 = "1";
    MOZ_DBUS_REMOTE = "1";
  };

  programs.librewolf = {
    enable = true;
    package = pkgs.librewolf-wayland.override (_attrs: {
      extraPrefs = ''
        pref("webgl.disabled", false);
        pref("privacy.resistFingerprinting", false);
      '' + extraPrefs;
      inherit nativeMessagingHosts;
    });
  };

  programs.firefox = {
    enable = lib.mkDefault true;
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
      "--ozone-platform=wayland"
    ];
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "pgdnlhfefecpicbbihgmbmffkjpaplco" # ublock extra
      "naepdomgkenhinolocfifgehidddafch" # browserpass
    ];
  };
}
