{ lib, inputs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.default ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.fpletz = ../home/fpletz.nix;
    extraSpecialArgs = {
      inherit inputs;
    };
  };

  users = {
    users.fpletz = {
      uid = 1000;
      isNormalUser = true;
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
      home = "/home/fpletz";
      shell = "/run/current-system/sw/bin/zsh";
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

  nix.settings.trusted-users = [ "fpletz" ];
}
