{ lib, config, ... }:
{
  options.bpletza.workstation.x11 = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.sway;
  };

  config = lib.mkIf config.bpletza.workstation.x11 {
    xresources.properties = {
      "Xft.hinting" = "1";
      "Xft.hintstyle" = "hintslight";
      "Xft.antialias" = "1";
      "Xft.rgba" = "rgb";
    };
    services.xsettingsd = {
      enable = true;
      settings = {
        "Xft/Hinting" = true;
        "Xft/HintStyle" = "hintslight";
        "Xft/Antialias" = true;
        "Xft/RGBA" = "rgb";
      };
    };
  };
}
