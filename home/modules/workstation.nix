{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.bpletza.workstation;
in
{
  options.bpletza.workstation.enable = lib.mkOption {
    type = lib.types.bool;
    default = osConfig.bpletza.workstation.enable or false;
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        nixfmt-rfc-style
        docker-compose
        podman-compose
        stdmanpages
        man-pages
        man-pages-posix
        python3Packages.ptpython
        (ncmpcpp.overrideAttrs (
          {
            configureFlags ? [ ],
            ...
          }:
          {
            configureFlags = configureFlags ++ [ "--with-boost=${boost.dev}" ];
          }
        ))
        mpc-cli
        sipcalc
        units
        sops
        nurl
        nix-tree
        playerctl
        python3
        uv
        yt-dlp
        pass
        gopass
        just
        git-annex
        git-remote-gcrypt
        rclone

        # GUI
        virt-manager
        virt-viewer
        transmission-remote-gtk
        mumble
        gimp3
        claws-mail
        keepassxc

        # LSP servers
        nil
        nixd
        ruff
        yaml-language-server
        rust-analyzer
        lua-language-server
        marksman
        texlab
        jq-lsp
        gopls
        docker-language-server
        docker-compose-language-service
        bash-language-server
        mesonlsp
        taplo
        llvmPackages.clang
      ]
      ++ (lib.optionals pkgs.stdenv.isx86_64 [ pkgs.lurk ]);

    programs.helix = {
      enable = true;
      settings = {
        theme = "tokyonight";
        editor = {
          statusline = {
            left = [
              "mode"
              "spinner"
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
            ];
            center = [ "version-control" ];
            right = [
              "diagnostics"
              "selections"
              "register"
              "position"
              "position-percentage"
              "file-encoding"
              "file-line-ending"
              "file-type"
            ];
            separator = "│";
            mode = {
              normal = "";
              insert = "󰌌";
              select = "󰒅";
            };
          };
          lsp = {
            display-progress-messages = true;
            display-inlay-hints = true;
          };
          end-of-line-diagnostics = "hint";
          inline-diagnostics.cursor-line = "warning";
          indent-guides = {
            render = true;
            character = "╎";
            skip-levels = 1;
          };
          gutters = {
            layout = [
              "diagnostics"
              "spacer"
              "line-numbers"
              "spacer"
              "diff"
            ];
          };
          whitespace = {
            render = {
              space = "all";
              tab = "all";
              nbsp = "all";
              nnbsp = "all";
              newline = "none";
            };
            characters = {
              space = "·";
              nbsp = "⍽";
              nnbsp = "␣";
              tab = "→";
              newline = "⏎";
              tabpad = "·";
            };
          };
        };
      };
      languages = {
        language-server = {
          nixd = {
            command = "nixd";
            config =
              let
                localFlake = ''(builtins.getFlake "/home/fpletz/src/flake")'';
              in
              {
                nixpkgs.expr = "import <nixpkgs> {}";
                formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
                options = {
                  nixos.expr = "${localFlake}.nixosConfigurations.server.options";
                  home-manager.expr = "${localFlake}.homeConfigurations.fpletz.options";
                };
              };
          };
        };
      };
    };

    programs.neovide = {
      enable = true;
      settings = {
        fork = true;
        font = {
          normal = [ "0xProto" ];
          size = 10;
          hinting = "full";
          edging = "antialias";
        };
      };
    };

    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };

    systemd.user.services.keepassxc = {
      Unit = {
        Description = "KeepassXC";
        PartOf = [ "graphical-session.target" ];
        After = [
          "graphical-session.target"
          "waybar.service"
        ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = lib.getExe pkgs.keepassxc;
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
