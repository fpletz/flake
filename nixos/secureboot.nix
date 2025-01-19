{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  options.bpletza.secureboot = lib.mkEnableOption "Secure Boot";

  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = lib.mkIf config.bpletza.secureboot {
    environment.systemPackages = [
      pkgs.sbctl
    ];

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
