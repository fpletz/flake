{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./default/networking.nix
    ./default/nginx.nix
    ./default/openssh.nix
    ./default/postgresql.nix
    ./default/tools.nix
    ./default/zram.nix
    inputs.disko.nixosModules.default
    inputs.sops-nix.nixosModules.sops
  ];

  nixpkgs.overlays = [
    inputs.self.overlays.default
    inputs.bad_gateway.overlays.default
    inputs.nixd.overlays.default
  ];

  nixpkgs.flake = {
    source = lib.mkDefault inputs.nixpkgs;
    setNixPath = lib.mkDefault true;
    setFlakeRegistry = lib.mkDefault true;
  };

  sops.defaultSopsFile = ../secrets.yaml;

  time.timeZone = "UTC";
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  boot = {
    enableContainers = false;
    tmp.useTmpfs = lib.mkDefault true;
    kernelPackages = lib.mkOverride 1001 pkgs.linuxPackages_latest;
    initrd = {
      compressor = "zstd";
      compressorArgs = [ "-19" ];
    };
    loader = {
      timeout = lib.mkForce 2;
      grub.splashImage = null;
      systemd-boot.configurationLimit = 10;
    };
    kernel.sysctl = {
      # fail fast on oom
      "vm.oom_kill_allocating_task" = 1;
    };
    supportedFilesystems = {
      zfs = false;
      bcachefs = true;
      btrfs = true;
    };
  };

  documentation = {
    # regular manpages are enough
    doc.enable = false;
    info.enable = false;
    nixos.extraModules = [ inputs.self.nixosModules.all ];
  };

  fonts.fontconfig.enable = lib.mkDefault false;

  xdg = {
    autostart.enable = lib.mkDefault false;
    icons.enable = lib.mkDefault false;
    menus.enable = lib.mkDefault false;
    mime.enable = lib.mkDefault false;
    sounds.enable = false;
  };

  users = {
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
    users.root = {
      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINybMKbAmqSwg56v39jAqgN+57JgZnm4CTAg6iZ6dF52AAAABHNzaDo="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK20Lv3TggAXcctelNGBxjcQeMB4AqGZ1tDCzY19xBUV"
      ];
    };
  };

  system = {
    # living on the edge
    stateVersion = lib.mkOverride 1001 config.system.nixos.version;

    # show a diff of the system closure on activation
    activationScripts.diff = ''
      if [[ -e /run/current-system ]]; then
        ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig"
      fi
    '';

    # include git rev of this repo/flake into the nixos-version
    configurationRevision = if inputs.self ? rev then lib.substring 0 8 inputs.self.rev else "dirty";

    nixos = {
      revision = inputs.nixpkgs.rev;
      versionSuffix = lib.mkForce ".${inputs.nixpkgs.shortRev}-${config.system.configurationRevision}";
    };

    switch = lib.mkDefault {
      enable = false;
      enableNg = true;
    };
  };

  nix = {
    # FIXME 2.24 hangs on every localbuild build for a long time trying to close fds until INT_MAX :/
    package = pkgs.nixVersions.nix_2_25;

    registry = {
      fpletz.flake = inputs.self;
    };

    channel.enable = false;

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "weekly";
      randomizedDelaySec = "42min";
    };

    optimise = {
      automatic = true;
      dates = [ "05:30" ];
    };

    settings = {
      trusted-users = [ "nix-build" ];
      connect-timeout = 3;
      http-connections = 150;
      extra-experimental-features = [
        "flakes"
        "nix-command"
      ];
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
        ovmf.packages = lib.mkForce [ pkgs.OVMFFull.fd ];
      };
      onShutdown = lib.mkDefault "shutdown";
      onBoot = lib.mkDefault "ignore";
      parallelShutdown = lib.mkDefault 2;
    };
  };

  services = {
    # I know how to find the nixos manual
    getty.helpLine = lib.mkForce "";

    # no google/cloudflare defaults
    resolved.fallbackDns = [ "" ];

    journald.extraConfig = ''
      SystemMaxUse=100M
      MaxRetentionSec=3days
    '';

    userborn.enable = true;

    prometheus = {
      exporters.node = {
        enable = lib.mkDefault true;
        enabledCollectors = [
          "systemd"
          "processes"
        ];
      };
    };

    btrfs.autoScrub = lib.mkIf (config.fileSystems."/".fsType == "btrfs") {
      enable = true;
      fileSystems = [ "/" ];
    };
  };
}
