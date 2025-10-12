{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.bpletza.secureboot = lib.mkEnableOption "Secure Boot";

  config = lib.mkIf config.bpletza.secureboot {
    environment.systemPackages = [
      pkgs.sbctl
    ];

    boot.loader = {
      limine = {
        enable = true;
        efiSupport = true;
        secureBoot.enable = true;
        extraEntries = ''
          /memtest86
            protocol: linux
            kernel_path: boot():///efi/memtest86/memtest.efi
          /netbootxyz
            protocol: efi
            path: boot():///efi/netbootxyz/netboot.xyz.efi
        '';
        additionalFiles = {
          "efi/memtest86/memtest.efi" = "${pkgs.memtest86plus.efi}";
          "efi/netbootxyz/netboot.xyz.efi" = "${pkgs.netbootxyz-efi}";
        };
      };
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };
  };
}
