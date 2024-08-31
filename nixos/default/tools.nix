{ lib, pkgs, ... }:
{
  programs = {
    zsh.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };
    mtr.enable = true;
    command-not-found.enable = lib.mkDefault false;
    tmux.enable = true;
    git.enable = true;
    htop.enable = true;
    iftop.enable = true;
    less = {
      enable = true;
      lessopen = null;
    };
  };

  environment.defaultPackages = [ ];

  environment.systemPackages = with pkgs; [
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
    # crypto
    age
    sops
    openssl
    # terminfos
    alacritty.terminfo
    kitty.terminfo
  ];
}
