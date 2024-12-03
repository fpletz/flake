{ ... }:
{
  networking.useNetworkd = true;

  boot.kernel.sysctl = {
    # Increase TCP buffer sizes for increased throughput
    "net.ipv4.tcp_rmem" = "4096	1000000	16000000";
    "net.ipv4.tcp_wmem" = "4096	1000000	16000000";

    # https://lwn.net/Articles/560082/
    "net.ipv4.tcp_notsent_lowat" = "131072";

    # For machines with a lot of UDP traffic increase the buffers
    "net.core.rmem_default" = 26214400;
    "net.core.rmem_max" = 26214400;
    "net.core.wmem_default" = 26214400;
    "net.core.wmem_max" = 26214400;

    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_timestamps" = 1;
    "net.ipv4.tcp_ecn" = 1;
    "net.ipv6.conf.all.keep_addr_on_down" = 1;

    # allow tcp and udp services in all VRFs
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
