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
  };

  imports = [ ./workstation/nvidia.nix ];

  config = mkIf cfg.enable {
    nixpkgs.permittedUnfreePackages = [ "corefonts" ];

    services.dbus.implementation = "broker";

    boot = {
      kernel.sysctl = {
        "vm.dirty_writeback_centisecs" = 3000;
        "net.core.default_qdisc" = "fq_codel";
        "net.ipv4.tcp_limit_output_bytes" = 65536;
        "fs.inotify.max_user_watches" = 524288;
        "kernel.nmi_watchdog" = 0;
      };
      kernelParams = [ "snd_hda_intel.power_save=1" ];
      extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
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
        memtest86.enable = config.nixpkgs.system == "x86_64-linux";
        efiSupport = mkDefault true;
      };
      loader.systemd-boot = {
        memtest86.enable = true;
        netbootxyz.enable = true;
      };
      kernelPackages = lib.mkIf (config.nixpkgs.system == "x86_64-linux") pkgs.linuxPackages-xanmod;
      initrd.systemd.enable = true;
      binfmt.emulatedSystems = lib.optional (config.nixpkgs.system == "x86_64-linux") "aarch64-linux";
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
        ACTION=="add|move", SUBSYSTEM=="net", ENV{INTERFACE}=="enp*", RUN+="${pkgs.ethtool}/bin/ethtool -s %k wol d"
        ACTION=="add|move", SUBSYSTEM=="net", ENV{INTERFACE}=="wlp*", RUN+="${pkgs.iw}/bin/iw dev %k set power_save on"
        ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
      '');

    services.avahi = {
      enable = true;
      ipv4 = true;
      ipv6 = true;
      allowInterfaces = [ "virbr0" ];
    };

    networking.wireless = {
      scanOnLowSignal = mkDefault true;
      extraConfig = ''
        preassoc_mac_addr=1
        mac_addr=1
        p2p_disabled=1
        passive_scan=1
        fast_reauth=1
      '';
      fallbackToWPA2 = false;
      userControlled.enable = true;
    };

    xdg.portal = {
      enable = true;
      config.common.default = [ "gtk" ];
      wlr = {
        enable = true;
        settings = {
          screencast = {
            max_fps = 30;
            chooser_type = "dmenu";
            chooser_cmd = "${lib.getExe pkgs.fuzzel} -d";
          };
        };
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr
      ];
    };

    security = {
      polkit.enable = true;
      pam.services = {
        swaylock = { };
        waylock = { };
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

    services.greetd =
      let
        command = "sway";
      in
      {
        enable = true;
        settings = {
          initial_session = {
            inherit command;
            user = "fpletz";
          };
          default_session.command = "${
            lib.makeBinPath [ pkgs.greetd.tuigreet ]
          }/tuigreet --time --cmd ${command}";
        };
      };

    powerManagement.cpuFreqGovernor = if cfg.battery then "schedutil" else "performance";

    hardware.graphics = {
      enable = true;
      extraPackages = (
        lib.optionals (config.nixpkgs.system == "x86_64-linux") (
          with pkgs;
          [
            libvdpau-va-gl
            vulkan-validation-layers
          ]
        )
      );
      enable32Bit = config.nixpkgs.system == "x86_64-linux";
      extraPackages32 = lib.optionals (config.nixpkgs.system == "x86_64-linux") (
        with pkgs.pkgsi686Linux;
        [
          libvdpau-va-gl
          vulkan-validation-layers
        ]
      );
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = config.nixpkgs.system == "x86_64-linux";
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
        pipewire."92-low-latency" = {
          context.properties = {
            default.clock.rate = 48000;
            default.clock.quantum = 128;
            default.clock.min-quantum = 32;
            default.clock.max-quantum = 1024;
          };
        };
        pipewire-pulse."92-low-latency" = {
          context.modules = [
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                pulse.min.req = "32/48000";
                pulse.default.req = "128/48000";
                pulse.max.req = "1024/48000";
                pulse.min.quantum = "32/48000";
                pulse.max.quantum = "1024/48000";
              };
            }
          ];
          stream.properties = {
            node.latency = "32/48000";
            resample.quality = 1;
          };
        };
        client.resample = {
          stream.properties = {
            resample.quality = 10;
          };
        };
      };
    };

    services.upower = {
      enable = cfg.battery;
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = mkDefault false;
      settings = {
        General = {
          Experimental = true;
          KernelExperimental = true;
        };
      };
    };

    environment.systemPackages = [ pkgs.alsa-utils ];

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    networking.firewall.trustedInterfaces = [ "podman+" ];

    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [
            "Fira Code"
            "Noto Color Emoji"
            "Font Awesome 6 Free"
            "Font Awesome 5 Free"
          ];
          sansSerif = [
            "Inter"
            "Noto Color Emoji"
            "Font Awesome 6 Free"
            "Font Awesome 5 Free"
          ];
          serif = [
            "Noto Serif"
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
        ubuntu_font_family
        gentium
        source-code-pro
        eb-garamond
        b612
        fira
        fira-code
        fira-code-symbols
        fira-mono
        noto-fonts
        powerline-fonts
        corefonts
        (nerdfonts.override (_: {
          fonts = [
            "FiraCode"
            "FiraMono"
            "SourceCodePro"
          ];
        }))
        meslo-lgs-nf
        inter
      ];
    };

    programs.adb.enable = config.nixpkgs.system == "x86_64-linux";
    programs.dconf.enable = true;
    programs.noisetorch.enable = true;
    programs.iotop.enable = true;
    programs.iftop.enable = true;
    programs.light.enable = true;
    programs.wireshark.enable = true;
    programs.flashrom.enable = true;
    programs.xwayland.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
      enableBrowserSocket = true;
    };
    systemd.user.services.gpg-agent.serviceConfig.ExecStart = lib.mkForce [
      ""
      ''
        ${config.programs.gnupg.package}/bin/gpg-agent --supervised \
          --pinentry-program ${pkgs.writers.writeBash "pinentry-chooser" ''
            if [ -z "$WAYLAND_DISPLAY" ]; then
              ${pkgs.pinentry-gnome3}/bin/pinentry "$@"
            else
              ${pkgs.pinentry-bemenu}/bin/pinentry-bemenu -b \
                --fn="Fira Mono 10" \
                --tf="#f7768e" \
                --tb="#2f3549" \
                --hf="#f7768e" \
                --hb="#2f3549" \
                "$@"
            fi
          ''}
      ''
    ];

    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      settings = {
        keep-outputs = true;
        keep-derivations = true;
      };
    };
  };
}
