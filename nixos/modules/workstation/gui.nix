{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.bpletza.workstation;
  inherit (lib) mkIf;
in
{
  options.bpletza.workstation = {
    gui = lib.mkOption {
      type = lib.types.bool;
      default = config.bpletza.workstation.enable;
      description = "GUI support";
    };
    ytdlVideoCodec = lib.mkOption {
      type = lib.types.str;
      default = "av01";
      description = "youtube-dl video codec";
    };
    ytdlMaxRes = lib.mkOption {
      type = lib.types.int;
      default = 1080;
      description = "youtube-dl maximum resolution";
    };
    internalDisplay = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Name of the internal display (e.g. eDP-1, LVDS-1).
      '';
    };
    displayScale = lib.mkOption {
      type = lib.types.nullOr lib.types.float;
      default = null;
      description = "Set scale of internal display";
    };
  };

  config = mkIf cfg.gui {
    xdg = {
      icons.enable = true;
      menus.enable = true;
      mime.enable = true;
      portal.enable = true;
    };

    hardware.graphics = {
      enable = true;
      extraPackages = lib.optionals (pkgs.stdenv.hostPlatform.isx86) [
        pkgs.vulkan-validation-layers
      ];
    };

    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [
            "CommitMono"
            "Noto Color Emoji"
            "Font Awesome 6 Free"
            "Font Awesome 5 Free"
          ];
          sansSerif = [
            "Inter"
            "Noto Color Emoji"
            "Font Awesome 6 Free"
            "Font Awesome 5 Free"
          ];
          serif = [
            "Noto Serif"
            "Noto Color Emoji"
            "Font Awesome 6 Free"
            "Font Awesome 5 Free"
          ];
        };
        subpixel = {
          rgba = lib.mkDefault "rgb";
        };
      };
      enableDefaultPackages = true;
      packages = with pkgs; [
        font-awesome_5
        font-awesome_6
        b612
        ubuntu-classic
        noto-fonts
        fira-code
        fira-mono
        fira-sans
        nerd-fonts.symbols-only
        inter
        commit-mono
        departure-mono
      ];
    };

    programs.dconf.enable = true;

    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    programs.ausweisapp = {
      enable = true;
      openFirewall = true;
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
      enableBrowserSocket = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    services.xserver = {
      xkb = {
        layout = "eu";
        options = "compose:caps";
      };
    };

    environment.systemPackages = [
      pkgs.pulseaudio
    ];
  };
}
