{
  lib,
  config,
  pkgs,
  inputs,
  osConfig,
  ...
}:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    inputs.stylix.homeModules.stylix
    inputs.spicetify-nix.homeManagerModules.default
  ]
  ++ lib.filesystem.listFilesRecursive ./modules;

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    polarity = "dark";
    override = {
      base00 = "16161E";
      base01 = "1A1B26";
      base02 = "2F3549";
      base03 = "444B6A";
      base04 = "787C99";
      base05 = "A9B1D6";
      base06 = "CBCCD1";
      base07 = "D5D6DB";
      base08 = "F7768E";
      base09 = "FF9E64";
      base0A = "E0AF68";
      base0B = "9ECE6A";
      base0C = "7DCFFF";
      base0D = "7AA2f7";
      base0E = "9D7CD8";
      base0F = "DB4B4B";
    };
    fonts = {
      monospace = {
        name = "CommitMono";
        package = pkgs.commit-mono;
      };
      sansSerif = {
        name = "Inter";
        package = pkgs.inter;
      };
      serif = {
        name = "Noto Serif";
        package = pkgs.noto-fonts;
      };
      sizes = {
        applications = 9;
        desktop = 9;
        terminal = 10;
      };
    };
    opacity = {
      terminal = 0.8;
    };
    targets = {
      # stylix pulls in lots of dependencies we don't need on servers
      gtk.enable = false;
      qt.enable = false;
      gnome.enable = lib.mkDefault false;
      kde.enable = lib.mkDefault false;
      xresources.enable = lib.mkDefault false;
      font-packages.enable = lib.mkDefault false;
      fontconfig.enable = lib.mkDefault false;
      sxiv.enable = false;
      gnome-text-editor.enable = false;
    };
  };

  home = {
    username = "fpletz";
    homeDirectory = "/home/fpletz";
    stateVersion = "25.05";

    sessionVariables = {
      EMAIL = "fpletz@fnordicwalking.de";
      PAGER = "less";
      TZ = "Europe/Amsterdam";
    };

    packages =
      with pkgs;
      [
        iperf
        pv
        ncdu
        du-dust
        dua
        socat
        nmap
        pwgen
        wget
        dnsutils
        host
        whois
        traceroute
        nix-output-monitor
      ]
      ++ lib.optionals (pkgs.stdenv.isx86_64 && (osConfig.bpletza.workstation.gaming or false)) [
        steam
      ];
  };

  nix = {
    gc = {
      automatic = true;
      options = "-d";
      dates = "weekly";
      persistent = true;
    };
  };

  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;

  programs.nix-index.enable = false; # enabled by nix-index-database module
  programs.nix-index-database.comma.enable = config.bpletza.workstation.enable;

  programs.btop = {
    enable = true;
    settings = {
      update_ms = 1000;
      show_coretemp = false;
    };
  };

  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        memory_legend = "top-left";
        network_legend = "top-left";
        hide_table_gap = true;
        hide_time = true;
        enable_cache_memory = true;
        network_use_log = true;
      };
    };
  };

  programs.htop.enable = true;

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    extraOptions = [ "--group-directories-first" ];
  };

  programs.jq.enable = true;

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    clock24 = true;
    terminal = "screen-256color";
    baseIndex = 1;
    extraConfig = ''
      set -g set-titles on
      set -g set-titles-string "#H: #W"
    '';
    plugins = [
      pkgs.tmuxPlugins.pain-control
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
    };
  };
}
