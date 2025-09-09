{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.bpletza.workstation.shell = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.bpletza.workstation.shell {
    programs.nushell = {
      enable = true;
      environmentVariables = {
        CARAPACE_BRIDGES = "zsh,bash,inshellisense";
      };
      settings = {
        show_banner = false;
        completions = {
          case_sensitive = false;
          algorithm = "fuzzy";
          quick = true;
          partial = true;
        };
      };
    };

    programs.zsh = {
      enable = true;
      history = {
        expireDuplicatesFirst = true;
        size = 10000000;
        save = 10000000;
      };
      initContent = lib.mkMerge [
        (lib.mkOrder 90 ''
          if [ -n "''${ZSH_DEBUGRC+1}" ]; then
            zmodload zsh/zprof
          fi
        '')
        (lib.mkOrder 9000 ''
          if [ -n "''${ZSH_DEBUGRC+1}" ]; then
            zprof
          fi
        '')
      ];
      plugins = [
        {
          name = "nix-zsh-completions";
          src = "${pkgs.nix-zsh-completions}/share/zsh/plugins/nix";
        }
        {
          name = "fast-syntax-highlighting";
          inherit (pkgs.zsh-fast-syntax-highlighting) src;
        }
      ];
      shellAliases = {
        p = "$PAGER";
        vi = "vim";
      };
    };

    programs.bash = {
      enable = true;
      historyFileSize = 1000000;
      historyIgnore = [ "exit" ];
      shellAliases = {
        vi = "vim";
      };
    };

    programs.zoxide.enable = config.bpletza.workstation.enable;

    programs.direnv = {
      enable = config.bpletza.workstation.enable;
      nix-direnv.enable = true;
    };

    programs.fzf = {
      enable = true;
      changeDirWidgetCommand = "fd --type d --color always";
      changeDirWidgetOptions = [
        "--ansi"
        "--preview 'tree -C {} | head -200'"
      ];
      defaultCommand = "fd --type f --color always";
      fileWidgetCommand = "fd --type f --color always";
      fileWidgetOptions = [
        "--ansi"
        "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
      ];
    };

    programs.starship = {
      enable = true;
      settings =
        lib.attrsets.recursiveUpdate (builtins.fromTOML (builtins.readFile ./shell/starship-presets.toml))
          {
            command_timeout = 2000;
            status.disabled = false;
            username = {
              disabled = false;
              style_user = "bold cyan";
              format = "[$user]($style)[@](white bold)";
              show_always = true;
            };
            hostname = {
              disabled = false;
              style = "bold blue";
              format = "[$ssh_symbol$hostname]($style) ";
              ssh_symbol = "󰣀";
              ssh_only = false;
            };
            directory = {
              disabled = false;
              truncation_length = 23;
              truncation_symbol = "…/";
            };
            direnv = {
              disabled = false;
              format = "[$symbol$loaded$allowed]($style) ";
              symbol = "󰚝 ";
              loaded_msg = "";
              unloaded_msg = " ";
              allowed_msg = "";
              not_allowed_msg = "󰌾";
              denied_msg = "󰌾";
            };
            nix_shell = {
              disabled = false;
              format = "[$symbol$state(\($name\))]($style) ";
              symbol = " ";
              impure_msg = "*";
              pure_msg = "";
              unknown_msg = "?";
            };
            shell.disabled = false;
            battery.disabled = false;
            git_branch = {
              disabled = false;
              symbol = " ";
              format = "[$symbol$branch(:$remote_branch)]($style) ";
            };
            git_commit = {
              disabled = false;
              tag_disabled = false;
            };
            package.disabled = true;
            aws.disabled = true;
            azure.disabled = true;
            gcloud.disabled = true;
            vcsh.disabled = true;
          };
    };

    programs.atuin = {
      enable = true;
      daemon.enable = true;
      settings = {
        update_check = false;
        style = "compact";
        show_tabs = false;
        inline_height_shell_up_key_binding = 5;
        serch_mode = "skim";
        filter_mode_shell_up_key_binding = "session";
        stats.common_prefix = [
          "sudo"
          "run0"
          ","
        ];
        auto_sync = false;
        sync.records = true;
        cwd_filter = [ "^/home/fpletz/.password-store" ];
      };
    };

    programs.carapace = {
      enable = true;
    };
    home.sessionVariables = {
      CARAPACE_EXCLUDES = "nix-build,nix-channel,nix-instantiate,nix-shell,nix,nixos-rebuild,man";
    };
  };
}
