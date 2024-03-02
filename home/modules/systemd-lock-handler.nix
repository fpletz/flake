{ lib, config, inputs, pkgs, ... }:
{
  options.bpletza.workstation.swaylock = lib.mkOption
    {
      type = lib.types.bool;
      default = config.options.bpletza.workstation.swaylock;
    };

  config = lib.mkIf config.options.bpletza.workstation.systemd-lock-handler {
    systemd.user.services.systemd-lock-handler = {
      Service = {
        ExecStart = "${inputs.self.packages.${pkgs.system}.systemd-lock-handler}/bin/systemd-lock-handler";
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
