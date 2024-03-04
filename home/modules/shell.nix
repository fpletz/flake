{ config, pkgs, lib, osConfig, ... }:
{
  options.bpletza.workstation.shell = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.bpletza.workstation.shell {
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

    programs.bash = {
      enable = true;
      historyFileSize = 1000000;
      historyIgnore = [ "exit" ];
      shellAliases = {
        vi = "vim";
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

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

    programs.starship = {
      enable = osConfig.bpletza.workstation.enable;
      enableZshIntegration = false;
      settings =
        lib.attrsets.recursiveUpdate
          (builtins.fromTOML (builtins.readFile ./shell/starship-presets.toml))
          {
            character = {
              success_symbol = "[➜](bold green)";
              error_symbol = "[➜](bold red)";
            };
            aws.disabled = false;
            azure.disabled = true;
            gcloud.disabled = true;
            shell.disabled = false;
            battery.disabled = false;
            status.disabled = false;
          };
    };

    programs.dircolors = {
      enable = true;
      settings = lib.importJSON ../../static/dircolors.json;
    };
  };
}
