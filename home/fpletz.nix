{ pkgs
, inputs
, ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./nixvim
  ];

  home = {
    username = "fpletz";
    homeDirectory = "/home/fpletz";
    stateVersion = "23.05";
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

      # FIXME: wants to write into plugin store path for cache
      fast-theme -q ${pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/zsh-fsh/main/themes/catppuccin-mocha.ini";
        hash = "sha256-7eIiR+ERWFXOq7IR/VMZqGhQgZ8uQ4jfvNR9MWgMSuk=";
      }} 2>/dev/null
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_mocha";
    };
  };
  home.file.".config/btop/themes/catppuccin_mocha.theme".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/btop/main/themes/catppuccin_mocha.theme";
    hash = "sha256-TeaxAadm04h4c55aXYUdzHtFc7pb12e0wQmCjSymuug=";
  };

  programs.bottom.enable = true;

  programs.htop.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    extraConfig = {
      user = {
        name = "Franz Pletz";
        email = "fpletz@fnordicwalking.de";
        signingkey = "792617B4";
      };
      url = {
        "git@git.sr.ht:~".insteadOf = "sh:";
        "git@github.com:".insteadOf = "gh:";
      };
      color = {
        ui = true;
        diff-highlight = {
          oldNormal = "red bold";
          oldHighlight = "red bold 52";
          newNormal = "green bold";
          newHighlight = "green bold 22";
        };
        diff = {
          meta = "11";
          frag = "magenta bold";
          func = "146 bold";
          commit = "yellow bold";
          old = "red bold";
          new = "green bold";
          whitespace = "red reverse";
        };
      };
      core = {
        quotePath = false;
      };
      merge.tool = "vimdiff";
      blame.date = "short";
      rerere.enabled = true;
      pull.rebase = true;
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      rebase = {
        stat = true;
        autostash = true;
      };
      commit = {
        gpgsign = true;
        verbose = true;
      };
      diff = {
        algorithm = "histogram";
        sopsdiffer.textconv = "sops -d";
      };
    };
    aliases = {
      bp = "cherry-pick -x";
      co = "commit -v";
      cpa = "cherry-pick --abort";
      cpc = "cherry-pick --continue";
      pfush = "push --force-with-lease --force-if-includes";
    };
    diff-so-fancy = {
      enable = true;
    };
  };

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
    # catppuccin-mocha
    colors = {
      "bg+" = "#313244";
      bg = "#1e1e2e";
      spinner = "#f5e0dc";
      hl = "#f38ba8";
      fg = "#cdd6f4";
      header = "#f38ba8";
      info = "#cba6f7";
      pointer = "#f5e0dc";
      marker = "#f5e0dc";
      "fg+" = "#cdd6f4";
      prompt = "#cba6f7";
      "hl+" = "#f38ba8";
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
    '';
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = "set -g @catppuccin_flavour 'mocha'";
      }
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "catppuccin";
    };
    themes = {
      catppuccin = builtins.readFile (pkgs.fetchFromGitHub
        {
          owner = "catppuccin";
          repo = "bat";
          rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
          hash = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
        }
      + "/Catppuccin-mocha.tmTheme");
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = false;
    settings =
      lib.attrsets.recursiveUpdate
        (
          builtins.fromTOML (
            builtins.readFile (pkgs.runCommand "starship-presets" { HOME = "/tmp"; } ''
              ${pkgs.starship}/bin/starship preset nerd-font-symbols > $out
            '')
          )
        )
        {
          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
          };
          aws.disabled = true;
          azure.disabled = true;
          gcloud.disabled = true;
          shell.disabled = false;
          git_status.disabled = true;
          hg_branch.disabled = false;
          battery.disabled = false;
          status.disabled = false;
        };
  };
}
