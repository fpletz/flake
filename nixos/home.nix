{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.fpletz = ../home/default.nix;
  };

  users = {
    users.fpletz = {
      uid = 1000;
      isNormalUser = true;
      password = "test"; # FIXME
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

  nix.settings.trusted-users = ["fpletz"];
}
