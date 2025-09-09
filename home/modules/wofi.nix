{ lib, config, ... }:
{
  options.bpletza.workstation.wofi = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.wayland;
  };

  config = lib.mkIf config.bpletza.workstation.wofi {
    programs.wofi = {
      enable = true;
      settings = {
        insensitive = true;
      };
    };
  };
}
