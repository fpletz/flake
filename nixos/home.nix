{
  lib,
  inputs,
  config,
  ...
}:
let
  cfg = config.bpletza.home;
in
{
  options.bpletza.home = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "home management for user";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "fpletz";
      description = "username";
    };
    passwordFromSecrets = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use secrets for password hash";
    };
  };

  imports = [ inputs.home-manager.nixosModules.default ];

  config = lib.mkIf cfg.enable {
    sops.secrets."${cfg.user}-password" = lib.mkIf cfg.passwordFromSecrets {
      neededForUsers = true;
    };

    home-manager = lib.mkIf (!config.boot.isContainer) {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${cfg.user} = ../home/${cfg.user}.nix;
      extraSpecialArgs = {
        inherit inputs;
      };
    };

    users = {
      users.${cfg.user} = {
        uid = 1000;
        isNormalUser = true;
        hashedPasswordFile =
          lib.mkIf cfg.passwordFromSecrets
            config.sops.secrets."${cfg.user}-password".path;
        group = "users";
        extraGroups = [
          "wheel"
          "libvirtd"
          "audio"
          "video"
          "docker"
          "sway"
          "wireshark"
          "adbusers"
          "input"
          "podman"
          "systemd-journal"
        ];
        home = "/home/${cfg.user}";
        shell = "/run/current-system/sw/bin/fish";
        linger = lib.mkDefault true;
        subGidRanges = [
          {
            count = 65536;
            startGid = 100001;
          }
        ];
        subUidRanges = [
          {
            count = 65536;
            startUid = 100001;
          }
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK20Lv3TggAXcctelNGBxjcQeMB4AqGZ1tDCzY19xBUV"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCs/VM56N9OsG/hK7LEwheHwptClBNPdBl/tIW8URWyQPsE0dN2FYAERsHom3I3IvAS3phfhYtLOwrQ+MqEt7u5f/E3CgdfvEFRER12arxlT/q3gSh5rUdq508fTjkUNmJr6Vul+BCZ7VeESa2yvvTesFqvdVP9NtpGbAusX/JCrXwQciygJ0hDuMdLFW8MmRzljDoBsyjz18MDaMzsGQddQuE+3uAzJ1NXZpNh+M+C6eLNe+QJQMb9VTPGB3Pc0cU0GWyXYpWTVkpJqJVe180ldMU9x2c2sBBcRM3N/UDn2MF3XQi3TdGO93AIcUHNCLmUvIdqz+DPdKzCt3c3HvHh"
        ];
      };
    };

    nix.settings.trusted-users = [ cfg.user ];
  };
}
