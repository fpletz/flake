{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    inputs.nix-colors.homeManagerModule
    inputs.nixvim.homeManagerModules.nixvim
    inputs.spicetify-nix.homeManagerModules.default
    ./nixvim
    ./modules/browser.nix
    ./modules/git.nix
    ./modules/gui.nix
    ./modules/i3status-rs.nix
    ./modules/nvidia.nix
    ./modules/shell.nix
    ./modules/spotify-unfree.nix
    ./modules/sway.nix
    ./modules/waylock.nix
    ./modules/systemd-lock-handler.nix
    ./modules/terminal.nix
    ./modules/obs.nix
    ./modules/waybar.nix
    ./modules/wob.nix
    ./modules/wofi.nix
    ./modules/workstation.nix
    ./modules/xorg.nix
  ];

  colorScheme = {
    # FIXME: inputs.nix-colors.colorSchemes."tokyo-night-dark";
    # Fixed version of tokyo-night-dark which should be tokyo-night-night
    # but seems mostly the same as tokyo-night-storm which is missing warm colors
    slug = "tokyo-night-night";
    name = "Tokyo Night Night";
    author = "fpletz";
    palette = {
      base00 = "#16161E";
      base01 = "#1A1B26";
      base02 = "#2F3549";
      base03 = "#444B6A";
      base04 = "#787C99";
      base05 = "#A9B1D6";
      base06 = "#CBCCD1";
      base07 = "#D5D6DB";
      base08 = "#F7768E";
      base09 = "#FF9E64";
      base0A = "#E0AF68";
      base0B = "#9ECE6A";
      base0C = "#7DCFFF";
      base0D = "#7AA2f7";
      base0E = "#9D7CD8";
      base0F = "#DB4B4B";
    };
  };

  home = {
    username = "fpletz";
    homeDirectory = "/home/fpletz";
    stateVersion = "24.05";

    sessionVariables = {
      EMAIL = "fpletz@fnordicwalking.de";
      PAGER = "less";
      TZ = "Europe/Amsterdam";
    };

    packages = with pkgs; [
      iperf
      pv
      ncdu
      du-dust
      dua
      socat
      nmap
      pwgen
      wget
      yq
      dnsutils
      host
      whois
      traceroute
    ];
  };

  nix = {
    gc = {
      automatic = true;
      options = "-d";
      frequency = "weekly";
      persistent = true;
    };
  };

  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;
  programs.nix-index-database.comma.enable = config.bpletza.workstation.enable;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
      update_ms = 1000;
      show_coretemp = false;
    };
  };

  programs.bottom.enable = true;

  programs.htop.enable = true;

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    extraOptions = [ "--group-directories-first" ];
  };

  home.file.".config/eza/theme.yml".source = "${pkgs.vimPlugins.tokyonight-nvim}/extras/eza/tokyonight.yml";

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
      source-file ${pkgs.vimPlugins.tokyonight-nvim}/extras/tmux/tokyonight_night.tmux
    '';
    plugins = [
      pkgs.tmuxPlugins.pain-control
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10' # minutes
        '';
      }
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "tokyonight_dark";
    };
    themes =
      let
        src = "${pkgs.vimPlugins.tokyonight-nvim}/extras/sublime";
      in
      {
        tokyonight = {
          inherit src;
          file = "tokyonight_night.tmTheme";
        };
        tokyonight_dark = {
          inherit src;
          file = "tokyonight_night.tmTheme";
        };
        tokyonight_day = {
          inherit src;
          file = "tokyonight_day.tmTheme";
        };
      };
  };
}
