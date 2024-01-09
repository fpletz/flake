{ config
, lib
, ...
}: {
  config = lib.mkIf config.services.postgresql.enable {
    services.postgresql = {
      settings = {
        max_connections = "20";
        shared_buffers = "256MB";
        effective_cache_size = "768MB";
        maintenance_work_mem = "128MB";
        checkpoint_completion_target = "0.9";
        wal_buffers = "7864kB";
        default_statistics_target = "100";
        random_page_cost = "1.1";
        effective_io_concurrency = "200";
        work_mem = "6MB";
      };
    };

    services.prometheus.exporters.postgres = {
      enable = true;
      listenAddress = "[::]";
      runAsLocalSuperUser = true;
    };

    systemd.timers.postgresql-vacuumdb = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Tue..Sun *-*-* 5:00";
        Persistent = true;
      };
    };
    systemd.services.postgresql-vacuumdb = {
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        ExecStart = "${config.services.postgresql.package}/bin/vacuumdb -a";
      };
    };

    systemd.timers.postgresql-vacuumdb-full = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Mon *-*-* 5:00";
        Persistent = true;
      };
    };
    systemd.services.postgresql-vacuumdb-full = {
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
        ExecStart = "${config.services.postgresql.package}/bin/vacuumdb -a -f";
      };
    };
  };
}
