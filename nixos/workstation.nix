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
    enable = mkEnableOption "fpletz workstation";
    battery = mkEnableOption "machine has battery";
    xorg = mkEnableOption "xorg xserver support";
    libvirt = mkOption {
      type = types.bool;
      description = "libvirtd";
    };
    waybar.wiredInterface = mkOption {
      type = types.str;
      default = "enp*";
      description = "Interface name or wildcard for wired interface";
    };
    i3status-rs.blocks.temperatures = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      description = "temperature blocks in the config";
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
  };

  imports = lib.filesystem.listFilesRecursive ./workstation;

  config = mkIf cfg.enable {
    bpletza.workstation.libvirt = lib.mkOptionDefault (!cfg.battery);

    nixpkgs.permittedUnfreePackages = [ "corefonts" ];

    services.dbus.implementation = "broker";

    boot = {
      kernel.sysctl = {
        "vm.dirty_writeback_centisecs" = 3000;
        "net.ipv4.tcp_limit_output_bytes" = 65536;
        "fs.inotify.max_user_watches" = 524288;
        "kernel.nmi_watchdog" = 0;
      };
      kernelParams = [ "snd_hda_intel.power_save=1" ];
      extraModulePackages = with config.boot.kernelPackages; [
        v4l2loopback
        ddcci-driver
      ];
      extraModprobeConfig = ''
        options v4l2loopback video_nr=23,42 card_label="23,42" exclusive_caps=1
      '';
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
      kernelPackages = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 pkgs.linuxPackages-xanmod;
      initrd.systemd.enable = true;
      binfmt.emulatedSystems = lib.optional pkgs.stdenv.hostPlatform.isx86_64 "aarch64-linux";
    };

    systemd = {
      enableEmergencyMode = true;
      extraConfig = ''
        DefaultTimeoutStopSec=20s
      '';
    };

    services.udev.packages = with pkgs; [
      platformio
      android-udev-rules
    ];
    services.udev.extraRules =
      ''
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

        # Set power profile based on AC power state
        SUBSYSTEM=="power_supply", ATTRS{type}=="Mains", ATTRS{online}=="0", RUN+="${lib.getExe pkgs.power-profiles-daemon} set power-saver"
        SUBSYSTEM=="power_supply", ATTRS{type}=="Mains", ATTRS{online}=="1", RUN+="${lib.getExe pkgs.power-profiles-daemon} set balanced"

        # Rule for when switching to battery
        ACTION=="change", SUBSYSTEM=="power_supply", ATTRS{type}=="Mains", ATTRS{online}=="0", RUN+="${pkgs.systemd}/bin/systemd-run --machine=fpletz@.host --user ${lib.getExe pkgs.libnotify} -a Power -i battery-full 'Changing Power States' 'Using battery power'"
        # Rule for when switching to AC
        ACTION=="change", SUBSYSTEM=="power_supply", ATTRS{type}=="Mains", ATTRS{online}=="1", RUN+="${pkgs.systemd}/bin/systemd-run --machine=fpletz@.host --user ${lib.getExe pkgs.libnotify} -a Power -i battery-full-charging 'Changing Power States' 'Using AC power'"

        # Battery warnings
        SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="15", RUN+="${pkgs.systemd}/bin/systemd-run --machine=fpletz@.host --user ${lib.getExe pkgs.libnotify} -a Power -i battery-low 'Battery Power Low' 'Less than 15%% battery remaining'"
        SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="5", RUN+="${pkgs.systemd}/bin/systemd-run --machine=fpletz@.host --user ${lib.getExe pkgs.libnotify} -a Power -i battery-empty 'Battery Power Critical' 'Less than 5%% battery remaining'"

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
      polkit.enable = true;
      pam.services = {
        swaylock = { };
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
          value = "99999";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "hard";
          value = "99999";
        }
      ];
    };

    location = {
      latitude = 48.0;
      longitude = 11.0;
    };
    services.geoclue2.enable = false;
    services.udisks2.enable = true;

    services.logind = {
      powerKey = "lock";
      lidSwitch = "lock";
      lidSwitchDocked = "lock";
      lidSwitchExternalPower = "lock";
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        foomatic-filters
        gutenprint
      ];
    };

    powerManagement.cpuFreqGovernor = if cfg.battery then "schedutil" else "performance";

    hardware.graphics = {
      enable = true;
      extraPackages = lib.optionals (pkgs.stdenv.hostPlatform.isx86) [
        pkgs.libvdpau-va-gl
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
      enable = cfg.battery;
    };

    hardware.bluetooth = {
      enable = mkDefault true;
      powerOnBoot = mkDefault false;
      settings = {
        General = {
          Experimental = true;
          KernelExperimental = true;
        };
      };
    };

    environment.systemPackages = [
      pkgs.alsa-utils
      pkgs.pulsemixer
      pkgs.pamixer
      # pkgs.ncpamixer
    ] ++ lib.optional config.hardware.bluetooth.enable pkgs.bluetuith;

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
            "Recursive Mono Casual Static"
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
        ubuntu_font_family
        noto-fonts
        fira-code
        fira-mono
        fira-sans
        nerd-fonts.fira-code
        nerd-fonts.fira-mono
        inter
        commit-mono
        departure-mono
        recursive
      ];
    };

    programs.adb.enable = pkgs.stdenv.hostPlatform.isx86_64;
    programs.dconf.enable = true;
    programs.noisetorch.enable = true;
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

    programs.ssh.knownHosts =
      {
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
        keep-outputs = true;
        keep-derivations = true;
        substituters = lib.mkBefore [
          "https://nixos.tvix.store"
        ];
      };
      distributedBuilds = true;
      buildMachines =
        (lib.optionals (config.networking.hostName != "zocknix") [
          {
            hostName = "zocknix.evs";
            protocol = "ssh-ng";
            sshUser = "nix-build";
            sshKey = "/home/fpletz/.ssh/id_build";
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
          {
            hostName = "build-box.nix-community.org";
            protocol = "ssh-ng";
            maxJobs = 2;
            sshKey = "/home/fpletz/.ssh/id_build";
            sshUser = "fpletz";
            system = "x86_64-linux";
            supportedFeatures = [
              "kvm"
              "big-parallel"
              "nixos-test"
            ];
          }
        ])
        ++ [
          {
            hostName = "aarch64-build-box.nix-community.org";
            protocol = "ssh-ng";
            maxJobs = 8;
            sshKey = "/home/fpletz/.ssh/id_build";
            sshUser = "fpletz";
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
            sshKey = "/home/fpletz/.ssh/id_build";
            sshUser = "fpletz";
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
      enable = cfg.xorg;
      windowManager.i3.enable = cfg.xorg;
      displayManager.startx.enable = cfg.xorg;
      xkb = {
        layout = "eu";
        options = "compose:caps";
      };
    };

    services.syncthing = {
      enable = true;
      user = "fpletz";
      dataDir = "/home/fpletz";
      openDefaultPorts = true;
    };

    services.ollama = {
      enable = cfg.ai;
    };
  };
}
