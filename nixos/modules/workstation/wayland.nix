{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.bpletza.workstation;
in
{
  config = lib.mkIf cfg.gui {
    services.displayManager.noctalia-greeter = {
      enable = true;
      passwordlessSyncUsers = [ config.bpletza.home.user ];
    };

    programs.niri = {
      enable = true;
      useNautilus = false;
    };

    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };

    environment.systemPackages = [
      pkgs.xwayland-satellite
      pkgs.evtest
    ];
  };
}
