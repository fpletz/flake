{ lib, ... }:
{
  networking.useNetworkd = true;

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = lib.mkDefault "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv6.conf.all.keep_addr_on_down" = 1;
    "net.ipv4.udp_l3mdev_accept" = 1;
    "net.ipv4.tcp_l3mdev_accept" = 1;
  };

  services.resolved = {
    llmnr = "false";
    extraConfig = ''
      MulticastDNS=false
    '';
  };
}
