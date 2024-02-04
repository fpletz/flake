{ pkgs
, config
, inputs
, ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModule
    inputs.nixvim.homeManagerModules.nixvim
    ./nixvim
    ./modules/dircolors.nix
    ./modules/git.nix
    ./modules/gui.nix
    ./modules/wob.nix
    ./modules/wofi.nix
  ];

  colorScheme = inputs.nix-colors.colorSchemes."tokyo-night-dark";

  home = {
    username = "fpletz";
    homeDirectory = "/home/fpletz";
    stateVersion = "23.11";

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

  xresources.extraConfig = builtins.readFile "${pkgs.vimPlugins.tokyonight-nvim}/extras/xresources/tokyonight_night.Xresources";

  programs.bash = {
    enable = true;
    historyFileSize = 1000000;
    historyIgnore = [ "exit" ];
    shellAliases = {
      vi = "vim";
    };
  };

  programs.zsh = {
    enable = true;
    history = {
      expireDuplicatesFirst = true;
      size = 10000000;
      save = 10000000;
    };
    plugins = [
      {
        name = "nix-zsh-completions";
        src = "${pkgs.nix-zsh-completions}/share/zsh/plugins/nix";
      }
      {
        name = "zsh-window-title";
        src = pkgs.fetchFromGitHub {
          owner = "olets";
          repo = "zsh-window-title";
          rev = "v1.0.2";
          hash = "sha256-efLpDY+cIe2KhRFpTcm85mYUFlTa2ECTIFhP7hjuf+8=";
        };
      }
      {
        name = "fast-syntax-highlighting";
        inherit (pkgs.zsh-fast-syntax-highlighting) src;
      }
      {
        name = "zsh-vi-mode";
        src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      }
    ];
    sessionVariables = {
      ZSH_TMUX_AUTOSTART = "false";
      ZSH_TMUX_AUTOCONNECT = "false";
    };
    shellAliases = {
      p = "$PAGER";
      vi = "vim";
    };
    localVariables = {
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
    };
    initExtraFirst = ''
      # p10k prompt cache
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';
    initExtra = ''
      # fix fzf keybinds with zsh-vi-mode
      zvm_after_init_commands+=('source ${pkgs.fzf}/share/fzf/key-bindings.zsh')

      if [[ -r ~/.p10k.zsh ]]; then
        source ~/.p10k.zsh
      fi
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '';
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "Fira Code";
        size = 10.0;
      };
      scrolling = { history = 20000; };
      window.opacity = 0.95;
      hints = {
        enabled = [
          {
            regex = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`]+";
            command = "xdg-open";
            post_processing = true;
            mouse = {
              enabled = true;
              mods = "None";
            };
            binding = {
              key = "U";
              mods = "Control|Shift";
            };
          }
        ];
      };
      live_config_reload = true;
      import = [
        "${pkgs.vimPlugins.tokyonight-nvim}/extras/alacritty/tokyonight_night.toml"
      ];
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
    };
  };

  programs.bottom.enable = true;

  programs.htop.enable = true;

  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  programs.jq.enable = true;

  programs.fzf = {
    enable = true;
    changeDirWidgetCommand = "fd --type d --color always";
    changeDirWidgetOptions = [ "--ansi" "--preview 'tree -C {} | head -200'" ];
    defaultCommand = "fd --type f --color always";
    defaultOptions = [ "--ansi" ];
    fileWidgetCommand = "fd --type f --color always";
    fileWidgetOptions = [ "--ansi" "--preview 'bat --style=numbers --color=always --line-range :500 {}'" ];
    colors = with config.colorScheme.palette; {
      "bg+" = "#${base02}";
      bg = "#${base00}";
      spinner = "#${base06}";
      hl = "#${base08}";
      fg = "#${base05}";
      header = "#${base08}";
      info = "#${base0E}";
      pointer = "#${base06}";
      marker = "#${base06}";
      "fg+" = "#${base05}";
      prompt = "#${base0E}";
      "hl+" = "#${base08}";
    };
  };

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
