{ pkgs
, inputs
, ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModule
    inputs.nixvim.homeManagerModules.nixvim
    ./nixvim
    ./modules/browser.nix
    ./modules/dircolors.nix
    ./modules/git.nix
    ./modules/gui.nix
    ./modules/shell.nix
    ./modules/terminal.nix
    ./modules/wob.nix
    ./modules/wofi.nix
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
      set -g status-interval 0
      set -g status-right-length 0
      set -g set-titles on
      set -g set-titles-string "#H: #W"
    '' + (builtins.readFile "${pkgs.vimPlugins.tokyonight-nvim}/extras/tmux/tokyonight_night.tmux");
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
        tokyonight-dark = {
          inherit src;
          file = "tokyonight_night.tmTheme";
        };
        tokyonight_day = {
          inherit src;
          file = "tokyonight_dark.tmTheme";
        };
      };
  };

  programs.zathura = {
    enable = true;
    extraConfig = builtins.readFile "${pkgs.vimPlugins.tokyonight-nvim}/extras/zathura/tokyonight_night.zathurarc";
  };

  programs.feh = {
    enable = true;
    keybindings = {
      zoom_in = "plus";
      zoom_out = "minus";
    };
  };
}
