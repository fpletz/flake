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
  ];

  nixpkgs.overlays = [
    inputs.self.overlays.default
    inputs.bad_gateway.overlays.default
    inputs.nixd.overlays.default
  ];

  time.timeZone = "UTC";
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  boot = {
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
  };

  documentation = {
    # regular manpages are enough
    doc.enable = false;
    info.enable = false;
  };

  sound.enable = lib.mkDefault false;
  xdg.sounds.enable = false;

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
    configurationRevision = if inputs.self ? rev then lib.substring 0 8 inputs.self.rev else "dirty";

    nixos = {
      revision = inputs.nixpkgs.rev;
      versionSuffix = lib.mkForce ".${inputs.nixpkgs.shortRev}-${config.system.configurationRevision}";
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
        ovmf.packages = with pkgs; lib.mkForce [ OVMFFull.fd ];
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

    prometheus = {
      exporters.node = {
        enable = lib.mkDefault true;
        enabledCollectors = [
          "systemd"
          "processes"
        ];
      };
    };
  };
}
