{ pkgs
, inputs
, ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModule
    inputs.nixvim.homeManagerModules.nixvim
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
    ./modules/wob.nix
    ./modules/wofi.nix
    ./modules/x11.nix
  ];

  colorScheme = inputs.nix-colors.colorSchemes."tokyo-night-dark";

  home = {
    username = "fpletz";
    homeDirectory = "/home/fpletz";
    stateVersion = "23.11";

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

  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
    };
  };

  programs.bottom.enable = true;

  programs.htop.enable = true;

  programs.eza = {
    enable = true;
    enableAliases = true;
    git = true;
    icons = true;
    extraOptions = [
      "--group-directories-first"
    ];
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
    '' + (builtins.readFile "${pkgs.vimPlugins.tokyonight-nvim}/extras/tmux/tokyonight_night.tmux");
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
