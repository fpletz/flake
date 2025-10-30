{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.bpletza.workstation;
  inherit (lib)
    types
    mkEnableOption
    mkOption
    mkIf
    mkDefault
    ;
in
{
  options.bpletza.workstation = {
    enable = mkEnableOption "${config.bpletza.home.user} workstation";
    battery = mkEnableOption "machine has battery";
    libvirt = mkOption {
      type = types.bool;
      description = "libvirtd";
    };
    waybar.wiredInterface = mkOption {
      type = types.str;
      default = "enp*";
      description = "Interface name or wildcard for wired interface";
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
    gaming = mkEnableOption "gaming support";
    ai = mkEnableOption "AI";

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

  imports = lib.filesystem.listFilesRecursive ./workstation;

  config = mkIf cfg.enable {
    bpletza.workstation.libvirt = lib.mkOptionDefault (!cfg.battery);

    services.dbus.implementation = "broker";

    boot = {
      kernel.sysctl = {
        "vm.dirty_writeback_centisecs" = 3000;
        "net.ipv4.tcp_limit_output_bytes" = 65536;
        "fs.inotify.max_user_watches" = 524288;
        "kernel.nmi_watchdog" = 0;
      };
      kernelParams = [ "snd_hda_intel.power_save=1" ];
      loader.grub = {
        ipxe = {
          netbootxyz = ''
            dhcp
            chain --autofree https://boot.netboot.xyz
          '';
        };
        memtest86.enable = pkgs.stdenv.hostPlatform.isx86_64;
        efiSupport = mkDefault true;
      };
      loader.systemd-boot = {
        memtest86.enable = true;
        netbootxyz.enable = true;
      };
      initrd.systemd.enable = true;
      binfmt.emulatedSystems = lib.optional pkgs.stdenv.hostPlatform.isx86_64 "aarch64-linux";
    };

    systemd = {
      enableEmergencyMode = true;
      settings.Manager.DefaultTimeoutStopSec = "20s";
    };

    services.udev.extraRules = ''
      # SDRs
      ATTR{idVendor}=="1d50", ATTR{idProduct}=="604b", SYMLINK+="hackrf-jawbreaker-%k", TAG+="uaccess"
      ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", SYMLINK+="hackrf-one-%k", TAG+="uaccess"
      ATTR{idVendor}=="1d50", ATTR{idProduct}=="cc15", SYMLINK+="rad1o-%k", TAG+="uaccess"
      ATTR{idVendor}=="1fc9", ATTR{idProduct}=="000c", SYMLINK+="nxp-dfu-%k", TAG+="uaccess"

      # qmk macropad
      ATTR{idVendor}=="f1f1", ATTR{idProduct}=="0315", SYMLINK+="winry315-%k", TAG+="uaccess"

      # console/modem
      KERNEL=="ttyACM[0-9]*", TAG+="udev-acl", TAG+="uaccess"

      # pci runtime power management
      ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
    ''
    + (lib.optionalString cfg.battery ''
      ACTION=="add|move", SUBSYSTEM=="net", ENV{INTERFACE}=="enp*", RUN+="${lib.getExe pkgs.ethtool} -s %k wol d"
      ACTION=="add|move", SUBSYSTEM=="net", ENV{INTERFACE}=="wlp*", RUN+="${lib.getExe pkgs.iw} dev %k set power_save on"
      ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"

      # Autosuspend for Generic EMV Smartcard Reader
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2ce3", ATTR{idProduct}=="9563", TEST=="power/control", ATTR{power/control}="auto"

      # Rule for when switching to battery
      ACTION=="change", SUBSYSTEM=="power_supply", ATTRS{type}=="Mains", ATTRS{online}=="0", RUN+="${pkgs.systemd}/bin/systemd-run --machine=${config.bpletza.home.user}@.host --user ${lib.getExe pkgs.libnotify} -a Power -i battery-full 'Using battery power'"
      # Rule for when switching to AC
      ACTION=="change", SUBSYSTEM=="power_supply", ATTRS{type}=="Mains", ATTRS{online}=="1", RUN+="${pkgs.systemd}/bin/systemd-run --machine=${config.bpletza.home.user}@.host --user ${lib.getExe pkgs.libnotify} -a Power -i battery-full-charging 'Using AC power'"

      # Battery warnings
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="15", RUN+="${pkgs.systemd}/bin/systemd-run --machine=${config.bpletza.home.user}@.host --user ${lib.getExe pkgs.libnotify} -a Power -i battery-low 'Battery Power Low' 'Less than 15%% battery remaining'"
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="5", RUN+="${pkgs.systemd}/bin/systemd-run --machine=${config.bpletza.home.user}@.host --user ${lib.getExe pkgs.libnotify} -a Power -i battery-empty 'Battery Power Critical' 'Less than 5%% battery remaining'"

      # Suspend when battery is at 2%
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-2]", RUN+="${pkgs.systemd}/bin/systemctl suspend"
    '');

    xdg = {
      icons.enable = true;
      menus.enable = true;
      mime.enable = true;
      portal.enable = true;
    };

    security = {
      polkit = {
        enable = true;
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (subject.isInGroup("wheel")) {
              return polkit.Result.YES;
            }
          });
        '';
      };
      pam.loginLimits = [
        # Allow audio group to set RT priorities
        {
          domain = "@audio";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@audio";
          item = "rtprio";
          type = "-";
          value = "99";
        }
        {
          domain = "@audio";
          item = "nice";
          type = "soft";
          value = "-11";
        }
        {
          domain = "@audio";
          item = "nice";
          type = "hard";
          value = "-15";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "hard";
          value = "524288";
        }
      ];
    };

    location = {
      latitude = 48.0;
      longitude = 11.0;
    };
    services.geoclue2.enable = lib.mkForce false;
    services.udisks2.enable = true;
    services.gnome.gnome-keyring.enable = false;

    services.logind = {
      settings = {
        Login = {
          HandleLidSwitchDocked = "lock";
          HandleLidSwitchExternalPower = "lock";
          HandleLidSwitch = "lock";
          HandlePowerKey = "lock";
        };
      };
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        foomatic-filters
        gutenprint
      ];
    };
    services.system-config-printer.enable = true;
    programs.system-config-printer.enable = true;

    systemd.services."cups-browsed".wantedBy = lib.mkForce [ ];

    powerManagement.cpuFreqGovernor = if cfg.battery then "schedutil" else "performance";

    hardware.graphics = {
      enable = true;
      extraPackages = lib.optionals (pkgs.stdenv.hostPlatform.isx86) [
        pkgs.vulkan-validation-layers
      ];
      enable32Bit = pkgs.stdenv.hostPlatform.isx86_64 && cfg.gaming;
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = pkgs.stdenv.hostPlatform.isx86_64 && cfg.gaming;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
        };
      };
      extraConfig = {
        pipewire."90-networking" = {
          "context.modules" = [
            {
              name = "libpipewire-module-zeroconf-discover";
              args = {
                "pulse.latency" = 500;
              };
            }
          ];
        };
        pipewire."92-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 128;
            "default.clock.min-quantum" = 32;
            "default.clock.max-quantum" = 1024;
          };
        };
        pipewire-pulse."92-low-latency" = {
          "pulse.properties" = {
            "pulse.min.req" = "32/48000";
            "pulse.default.req" = "128/48000";
            "pulse.max.req" = "1024/48000";
            "pulse.min.quantum" = "32/48000";
            "pulse.max.quantum" = "1024/48000";
          };
          "stream.properties" = {
            "node.latency" = "32/48000";
            "resample.quality" = 8;
          };
        };
      };
    };

    services.upower = {
      enable = mkIf cfg.battery true;
    };

    hardware.bluetooth = {
      enable = mkDefault true;
      powerOnBoot = mkDefault true;
      settings = {
        General = {
          AutoConnect = true;
          MultiProfile = "multiple";
          Experimental = true;
          KernelExperimental = true;
        };
      };
    };

    environment.systemPackages = [
      pkgs.alsa-utils
      pkgs.pulsemixer
      pkgs.wiremix
      pkgs.efibootmgr
    ]
    ++ lib.optional config.hardware.bluetooth.enable pkgs.bluetuith;

    systemd.user.services.mpris-proxy.wantedBy = lib.mkIf config.hardware.bluetooth.enable [
      "graphical-session.target"
    ];

    services.uxplay = {
      enable = true;
    };

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [
            "0xProto"
            "Noto Color Emoji"
            "Font Awesome 6 Free"
            "Font Awesome 5 Free"
          ];
          sansSerif = [
            "Recursive Sans Casual Static"
            "Noto Color Emoji"
            "Font Awesome 6 Free"
            "Font Awesome 5 Free"
          ];
          serif = [
            "Recursive Sans Casual Static"
            "Noto Color Emoji"
            "Font Awesome 6 Free"
            "Font Awesome 5 Free"
          ];
        };
        subpixel = {
          rgba = mkDefault "rgb";
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

    programs.adb.enable = pkgs.stdenv.hostPlatform.isx86_64;
    programs.dconf.enable = true;
    programs.iotop.enable = true;
    programs.iftop.enable = true;
    programs.light.enable = true;
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
    };
    programs.flashrom.enable = true;
    programs.git.package = pkgs.git;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
      enableBrowserSocket = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    programs.nh.enable = true;

    programs.ssh.knownHosts = {
      "build-box.nix-community.org".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElIQ54qAy7Dh63rBudYKdbzJHrrbrrMXLYl7Pkmk88H";
      "aarch64-build-box.nix-community.org".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG9uyfhyli+BRtk64y+niqtb+sKquRGGZ87f4YRc8EE1";
      "darwin-build-box.nix-community.org".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMHhlcn7fUpUuiOFeIhDqBzBNFsbNqq+NpzuGX3e6zv";
    }
    // lib.genAttrs [ "zocknix" "zocknix.evs" ] (_: {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZwZu77INAei0k/SmiQU3F6a2iO6Pz17oxm7bHmoxTe";
    });

    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      settings = {
        keep-outputs = lib.mkDefault true;
        keep-derivations = true;
        substituters = lib.mkBefore [
          "https://cache.muc.ccc.de/muccc"
        ];
        trusted-public-keys = [
          "muccc:prppkBGhfZZniZyY/x9KZS0AnjgBQ7Ds22KmCgu1GZI="
        ];
      };
      distributedBuilds = true;
      buildMachines =
        lib.optionals (config.networking.hostName != "zocknix") [
          {
            hostName = "zocknix.evs";
            protocol = "ssh-ng";
            sshUser = "nix-build";
            sshKey = "/home/${config.bpletza.home.user}/.ssh/id_build";
            systems = [
              "i686-linux"
              "x86_64-linux"
            ];
            supportedFeatures = [
              "kvm"
              "big-parallel"
              "nixos-test"
            ];
            maxJobs = 10;
            speedFactor = 2;
          }
        ]
        ++ [
          {
            hostName = "aarch64-build-box.nix-community.org";
            protocol = "ssh-ng";
            maxJobs = 8;
            sshKey = "/home/${config.bpletza.home.user}/.ssh/id_build";
            sshUser = "${config.bpletza.home.user}";
            system = "aarch64-linux";
            supportedFeatures = [
              "kvm"
              "big-parallel"
              "nixos-test"
            ];
          }
          {
            hostName = "darwin-build-box.nix-community.org";
            protocol = "ssh-ng";
            maxJobs = 4;
            sshKey = "/home/${config.bpletza.home.user}/.ssh/id_build";
            sshUser = "${config.bpletza.home.user}";
            system = "aarch64-darwin";
            supportedFeatures = [
              "kvm"
              "big-parallel"
            ];
          }
        ];
    };

    virtualisation.libvirtd = {
      enable = cfg.libvirt;
    };

    services.xserver = {
      xkb = {
        layout = "eu";
        options = "compose:caps";
      };
    };

    services.syncthing = {
      enable = true;
      user = config.bpletza.home.user;
      dataDir = "/home/${config.bpletza.home.user}";
      openDefaultPorts = true;
    };

    services.ollama = {
      enable = cfg.ai;
      host = "[::]";
    };
  };
}
