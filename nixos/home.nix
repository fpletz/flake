{ inputs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.fpletz = ../home/fpletz.nix;
    extraSpecialArgs = { inherit inputs; };
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
    };
  };

  nix.settings.trusted-users = [ "fpletz" ];
}
