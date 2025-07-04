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
        ncmpcpp
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
        virt-manager
        virt-viewer
        mumble
        gimp
        claws-mail
        keepassxc
        swww
        tectonic
        just

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
        cmake-language-server
        taplo
        llvmPackages.clang
      ]
      ++ (lib.optionals pkgs.stdenv.isx86_64 [ pkgs.lurk ]);

    programs.neovide = {
      enable = true;
      settings = {
        fork = true;
        font = {
          normal = [ "Victor Mono" ];
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
