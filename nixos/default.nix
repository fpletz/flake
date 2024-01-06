{ lib
, config
, pkgs
, inputs
, ...
}: {
  time.timeZone = "UTC";
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  boot = {
    tmp = {
      useTmpfs = lib.mkDefault true;
      # zram to the rescue!
      tmpfsSize = "200%";
    };
    kernelPackages = lib.mkOverride 1001 pkgs.linuxPackages_latest;
    loader = {
      timeout = lib.mkForce 2;
      grub.splashImage = null;
      systemd-boot.configurationLimit = 10;
    };
    kernel.sysctl = {
      "vm.oom_kill_allocating_task" = 1;
      "vm.swappiness" = 100;
      "net.core.default_qdisc" = lib.mkDefault "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv6.conf.all.keep_addr_on_down" = 1;
      "net.ipv4.udp_l3mdev_accept" = 1;
      "net.ipv4.tcp_l3mdev_accept" = 1;
    };
  };

  networking.useNetworkd = true;

  # wait-online is broken :/
  systemd.network.wait-online.enable = false;

  # restart instead of stop/start
  systemd.services.systemd-networkd.stopIfChanged = false;
  systemd.services.systemd-resolved.stopIfChanged = false;

  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 100;
  };

  environment.systemPackages = with pkgs; [
    bottom
    perf-tools
    lsof
    ncdu
    du-dust
    dua
    tcpdump
    iptables
    ethtool
    openssl
    rsync
    borgbackup
    sshfs-fuse
    dmidecode
    pciutils
    usbutils
    hdparm
    lm_sensors
    parted
    ddrescue
    nmap
    netcat
    ngrep
    file
    which
    age
    sops
    ripgrep
    fd
    di
    pv
    ouch
    viddy
    alacritty.terminfo
  ];

  programs = {
    zsh.enable = true;
    vim.defaultEditor = true;
    mtr.enable = true;
    command-not-found.enable = lib.mkDefault false;
    tmux.enable = true;
    git.enable = true;
    htop.enable = true;
    iftop.enable = true;
  };

  documentation = {
    doc.enable = false;
    info.enable = false;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users = {
      # unprivileged user for ad-hoc remote builds
      nix-build = {
        uid = 1100;
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPjOA6BgQxco18WpX1TfN22zTOG/EwACxIWI3Ho+530f"
        ];
      };
    };
    users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK20Lv3TggAXcctelNGBxjcQeMB4AqGZ1tDCzY19xBUV"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs/VM56N9OsG/hK7LEwheHwptClBNPdBl/tIW8URWyQPsE0dN2FYAERsHom3I3IvAS3phfhYtLOwrQ+MqEt7u5f/E3CgdfvEFRER12arxlT/q3gSh5rUdq508fTjkUNmJr6Vul+BCZ7VeESa2yvvTesFqvdVP9NtpGbAusX/JCrXwQciygJ0hDuMdLFW8MmRzljDoBsyjz18MDaMzsGQddQuE+3uAzJ1NXZpNh+M+C6eLNe+QJQMb9VTPGB3Pc0cU0GWyXYpWTVkpJqJVe180ldMU9x2c2sBBcRM3N/UDn2MF3XQi3TdGO93AIcUHNCLmUvIdqz+DPdKzCt3c3HvHh"
    ];
  };

  system = {
    # living on the edge
    stateVersion = lib.mkDefault "23.11";

    # show a diff of the system closure on activation
    activationScripts.diff = ''
      if [[ -e /run/current-system ]]; then
        ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig"
      fi
    '';

    # include git rev of this repo/flake into the nixos-version
    configurationRevision =
      if inputs.self ? rev
      then lib.substring 0 8 inputs.self.rev
      else "dirty";

    nixos = {
      revision = inputs.nixpkgs.rev;
      versionSuffix =
        lib.mkForce
          ".${inputs.nixpkgs.shortRev}-${config.system.configurationRevision}";
    };

    # make deployment flake and nixpkgs available as well-known path
    extraSystemBuilderCmds = ''
      ln -s "${inputs.self}" "$out/flake"
      ln -s "${inputs.nixpkgs}" "$out/nixpkgs"
    '';
  };

  nix = {
    # set nixpkgs flake on the target to the input of the deployment
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      fpletz.flake = inputs.self;
    };

    nixPath = lib.mkForce [
      # use deployed nixpkgs flake
      "nixpkgs=/run/current-system/nixpkgs"
      # disable local nixos-rebuild
      "nixos-config=/dontuse"
    ];

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "weekly";
    };

    settings = {
      trusted-users = [ "nix-build" ];
      connect-timeout = 3;
      http-connections = 150;
      extra-experimental-features = [ "flakes" "nix-command" ];
      auto-optimise-store = true;
      builders-use-substitutes = true;
      log-lines = lib.mkDefault 25;
    };

    daemonCPUSchedPolicy = lib.mkDefault "batch";
    daemonIOSchedClass = lib.mkDefault "idle";
    daemonIOSchedPriority = lib.mkDefault 7;
  };
  systemd.services.nix-daemon.serviceConfig.LimitNOFILE = lib.mkForce "infinity";

  security.acme = {
    defaults.email = "fpletz@fnordicwalking.de";
    acceptTerms = true;
  };

  virtualisation = {
    libvirtd = {
      qemu = {
        swtpm.enable = true;
        ovmf.packages = with pkgs; lib.mkForce [ OVMFFull.fd ];
      };
      onShutdown = lib.mkDefault "shutdown";
      onBoot = lib.mkDefault "ignore";
      parallelShutdown = lib.mkDefault 2;
    };
  };

  services = {
    getty.helpLine = lib.mkForce "";

    # no google/cloudflare defaults
    resolved.fallbackDns = [ "" ];

    openssh = {
      enable = true;
      hostKeys = [
        # only ed25519 hostkey, no rsa
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
          bits = 256;
        }
      ];
      sftpFlags = [ "-f AUTHPRIV" "-l INFO" ];
      moduliFile = ../static/ssh-moduli;
      settings = {
        PasswordAuthentication = false;
        Ciphers = [ "chacha20-poly1305@openssh.com" ];
        KexAlgorithms = [ "curve25519-sha256@libssh.org" ];
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
        ];
        UseDns = false;
      };
    };

    journald.extraConfig = ''
      SystemMaxUse=100M
      MaxRetentionSec=3days
    '';

    nginx = {
      package = lib.mkDefault pkgs.nginxMainline;
      recommendedOptimisation = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault true;
      recommendedGzipSettings = lib.mkDefault true;
      recommendedBrotliSettings = lib.mkDefault true;
      recommendedProxySettings = lib.mkDefault true;
      resolver.addresses =
        let
          isIPv6 = addr: builtins.match "^[^\\[]*:.*:.*$" addr != null;
          escapeIPv6 = addr:
            if isIPv6 addr
            then "[${addr}]"
            else addr;
          cloudflare = [ "1.1.1.1" "[2606:4700:4700::1111]" ];
          resolvers =
            if config.networking.nameservers != [ ]
            then config.networking.nameservers
            else if config.services.resolved.enable
            then [ "127.0.0.53" ]
            else cloudflare;
        in
        map escapeIPv6 resolvers;
      logError = "stderr info";
      appendHttpConfig = ''
        log_format json escape=json '{ "time": "$time_iso8601", '
          '"remote_addr": "$remote_addr", '
          '"remote_user": "$remote_user", '
          '"ssl_protocol_cipher": "$ssl_protocol/$ssl_cipher", '
          '"body_bytes_sent": "$body_bytes_sent", '
          '"request_time": "$request_time", '
          '"status": "$status", '
          '"request": "$request", '
          '"request_method": "$request_method", '
          '"http_referrer": "$http_referer", '
          '"http_x_forwarded_for": "$http_x_forwarded_for", '
          '"http_cf_ray": "$http_cf_ray", '
          '"host": "$host", '
          '"server_name": "$server_name", '
          '"upstream_address": "$upstream_addr", '
          '"upstream_status": "$upstream_status", '
          '"upstream_response_time": "$upstream_response_time", '
          '"upstream_response_length": "$upstream_response_length", '
          '"upstream_cache_status": "$upstream_cache_status", '
          '"http_user_agent": "$http_user_agent" }';
        access_log syslog:server=unix:/dev/log,facility=local4,severity=debug,nohostname json;
      '';
    };

    prometheus = {
      exporters.node = {
        enable = lib.mkDefault true;
        enabledCollectors = [ "systemd" "processes" ];
      };
    };
  };
}
