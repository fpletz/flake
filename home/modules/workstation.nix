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
        tmate
        nil
        ruff
        uv
        yt-dlp
        pass
        gopass
        virt-manager
        virt-viewer
        mumble
        gimp
        (
          (claws-mail.overrideAttrs (_: {
            # FIXME: ugly hack for https://github.com/NixOS/nixpkgs/pull/389009
            postConfigure = ''
              substituteInPlace libtool \
                --replace-fail 'for search_ext in .la $std_shrext .so .a' 'for search_ext in $std_shrext .so .a'
            '';
          })).override
          (_: {
            enablePluginClamd = false;
          })
        )
        keepassxc
        swww
      ]
      ++ (lib.optionals pkgs.stdenv.isx86_64 [ pkgs.lurk ]);

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

    systemd.user.services.swww = {
      Unit = {
        Description = "swww";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = lib.getExe' pkgs.swww "swww-daemon";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
