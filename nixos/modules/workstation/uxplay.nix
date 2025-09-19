{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.uxplay;
in
{
  options.services.uxplay = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable the uxplay service.
      '';
    };

    basePort = lib.mkOption {
      type = lib.types.port;
      default = 35000;
      description = ''
        Base ports.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Open the firewall.
      '';
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Additional commandline paremters to add to uxplay binary.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
      openFirewall = cfg.openFirewall;
    };

    networking.firewall =
      let
        portRange = {
          from = cfg.basePort;
          to = cfg.basePort + 2;
        };
      in
      lib.mkIf cfg.openFirewall {
        allowedTCPPortRanges = [ portRange ];
        allowedUDPPortRanges = [ portRange ];
      };

    systemd.user.services.uxplay = {
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.uxplay} -p ${builtins.toString cfg.basePort} ${lib.concatStringsSep " " cfg.extraFlags}";
      };
    };
  };
}
