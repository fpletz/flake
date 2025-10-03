{ lib, pkgs, ... }:
{
  programs = {
    zsh = {
      enable = true;
      enableGlobalCompInit = false;
    };
    vim = {
      enable = true;
      defaultEditor = true;
    };
    mtr.enable = true;
    command-not-found.enable = lib.mkDefault false;
    tmux.enable = true;
    git = {
      enable = true;
      package = lib.mkDefault pkgs.gitMinimal;
    };
    htop.enable = true;
    iftop.enable = true;
    less = {
      enable = true;
      lessopen = null;
      envVariables = {
        LESS = "-FRX";
      };
    };
    bandwhich.enable = true;
  };

  environment.defaultPackages = [ ];

  environment.systemPackages = with pkgs; [
    # system
    molly-guard
    # introspection
    bottom
    perf-tools
    lsof
    strace
    # filesystem
    ncdu
    du-dust
    dua
    ripgrep
    fd
    di
    pv
    file
    which
    # netwoking
    tcpdump
    iptables
    ethtool
    rsync
    borgbackup
    sshfs-fuse
    nmap
    netcat
    ngrep
    # hardware
    dmidecode
    pciutils
    usbutils
    hdparm
    lm_sensors
    # disks
    parted
    ddrescue
    smartmontools
    # crypto
    age
    sops
    openssl
    # nix
    nix-output-monitor
    # terminfos
    alacritty.terminfo
    ghostty.terminfo
  ];
}
