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
        nixd
        ruff
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
      ]
      ++ (lib.optionals pkgs.stdenv.isx86_64 [ pkgs.lurk ]);

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
