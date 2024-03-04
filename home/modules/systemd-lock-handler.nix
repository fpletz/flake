{ lib, config, pkgs, ... }:
{
  options.services.systemd-lock-handler.enable = lib.mkEnableOption "systemd user session lock handler";

  config = lib.mkIf config.services.systemd-lock-handler.enable {
    systemd.user.services.systemd-lock-handler = {
      Service = {
        ExecStart = "${pkgs.systemd-lock-handler}/bin/systemd-lock-handler";
        Slice = "session.slice";
        Type = "notify";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.targets = {
      lock = {
        Unit = {
          Conflicts = [ "unlock.target" ];
          Description = "Lock the current session";
        };
      };
      unlock = {
        Unit = {
          Conflicts = [ "lock.target" ];
          Description = "Unlock the current session";
        };
      };
      sleep = {
        Unit = {
          Description = "User-level target triggered when the system is about to sleep";
          Requires = [ "lock.target" ];
          After = [ "lock.target" ];
        };
      };
    };
  };
}
