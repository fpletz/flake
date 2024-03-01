{ config
, lib
, pkgs
, inputs
, ...
}:
let
  cfg = config.bpletza.workstation;
  inherit (lib) types mkEnableOption mkOption mkIf;
in
{
  options.bpletza.workstation = {
    enable = mkEnableOption "fpletz workstation";
    battery = mkEnableOption "machine has battery";
    spotify = mkEnableOption "unfree spotify client";
    i3status-rs.blocks.temperatures = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      description = "temperature blocks in the config";
    };
  };

  imports = [
    ./workstation/nvidia.nix
  ];

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    services.dbus.implementation = "broker";

    boot = {
      kernel.sysctl = {
        "vm.dirty_writeback_centisecs" = 1500;
        "net.core.default_qdisc" = "fq_codel";
        "net.ipv4.tcp_limit_output_bytes" = 65536;
        "fs.inotify.max_user_watches" = 524288;
        "vm.laptop_mode" = 5;
      };
      kernelParams = [
        "snd_hda_intel.power_save=1"
        "transparent_hugepage=madvise"
      ];
      extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
      extraModprobeConfig = ''
        options v4l2loopback video_nr=23,42 card_label="23,42" exclusive_caps=1
      '';
      kernel.sysctl = {
        "vm.nr_overcommit_hugepages" = lib.mkDefault 512;
      };
      loader.grub = {
        ipxe = {
          netbootxyz = ''
            dhcp
            chain --autofree https://boot.netboot.xyz
          '';
        };
        memtest86.enable = config.nixpkgs.system == "x86_64-linux";
        efiSupport = lib.mkDefault true;
      };
      loader.systemd-boot = {
        memtest86.enable = true;
        netbootxyz.enable = true;
      };
      kernelPackages = lib.mkIf (config.nixpkgs.system == "x86_64-linux") (
        lib.modules.mkDefault pkgs.linuxPackages-xanmod
      );
    };

    systemd.tmpfiles.rules = [
      "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
      "w /sys/kernel/mm/transparent_hugepage/shmem_enabled - - - - within_size"
    ];

    systemd = {
      enableEmergencyMode = true;
      extraConfig = ''
        DefaultTimeoutStopSec=20s
      '';
    };

    services.udev.packages = with pkgs; [ platformio ];
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
    '';

    services.resolved = {
      llmnr = "false";
      extraConfig = ''
        MulticastDNS=false
      '';
    };

    services.avahi = {
      enable = true;
      ipv4 = true;
      ipv6 = true;
      allowInterfaces = [ "virbr0" ];
    };

    networking.wireless = {
      scanOnLowSignal = lib.mkDefault true;
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
            max_fps = 15;
            chooser_type = "dmenu";
            chooser_cmd = "${pkgs.wofi}/bin/wofi --show dmenu";
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
      pam.services.swaylock = { };
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
      drivers = with pkgs; [ foomatic-filters gutenprint ];
    };

    services.greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "sway";
          user = "fpletz";
        };
        default_session.command = "${lib.makeBinPath [pkgs.greetd.tuigreet]}/tuigreet --time --cmd sway";
      };
    };

    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs;
        (lib.optionals (config.nixpkgs.system == "x86_64-linux")
          [ libvdpau-va-gl vaapiVdpau vulkan-validation-layers ]);
      driSupport32Bit = config.nixpkgs.system == "x86_64-linux";
      extraPackages32 = with pkgs.pkgsi686Linux;
        lib.optionals (config.nixpkgs.system == "x86_64-linux")
          [ libvdpau-va-gl vaapiVdpau vulkan-validation-layers ];
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = config.nixpkgs.system == "x86_64-linux";
      pulse.enable = true;
      jack.enable = true;
    };

    services.upower = {
      enable = cfg.battery;
    };

    sound.enable = true;
    hardware.bluetooth = {
      enable = true;
      settings = {
        General = {
          Experimental = true;
          KernelExperimental = true;
        };
      };
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
    networking.firewall.trustedInterfaces = [ "podman+" ];

    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [ "Fira Code" "Font Awesome 6 Free" "Font Awesome 5 Free" "Noto Color Emoji" ];
          sansSerif = [ "Fira Sans" "Font Awesome 6 Free" "Font Awesome 5 Free" "Noto Color Emoji" ];
          serif = [ "Noto Serif" "Font Awesome 6 Free" "Font Awesome 5 Free" "Noto Color Emoji" ];
        };
        subpixel = {
          rgba = lib.mkDefault "rgb";
        };
      };
      packages = with pkgs; [
        cm_unicode
        dejavu_fonts
        font-awesome_5
        font-awesome_6
        ttf_bitstream_vera
        ubuntu_font_family
        unifont
        inconsolata
        proggyfonts
        gentium
        source-code-pro
        source-sans-pro
        source-serif-pro
        eb-garamond
        hack-font
        montserrat
        iosevka
        b612
        fira
        fira-code
        fira-code-symbols
        fira-mono
        noto-fonts
        noto-fonts-emoji
        powerline-fonts
        corefonts
        (nerdfonts.override (_: {
          fonts = [ "FiraCode" "FiraMono" "BitstreamVeraSansMono" "DejaVuSansMono" "DroidSansMono" "Inconsolata" ];
        }))
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
      pinentryFlavor = "gnome3";
    };
    systemd.user.services.gpg-agent.serviceConfig.ExecStart = lib.mkForce [
      ""
      ''
        ${config.programs.gnupg.package}/bin/gpg-agent --supervised \
          --pinentry-program ${pkgs.writers.writeBash "pinentry-chooser" ''
          if [ -z "$WAYLAND_DISPLAY" ]; then
            ${pkgs.pinentry.gnome3}/bin/pinentry "$@"
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
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.fpletz = ../home/fpletz.nix;
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
