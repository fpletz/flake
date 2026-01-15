{ lib, ... }:
{
  networking.useNetworkd = true;

  systemd.network = {
    wait-online.anyInterface = true;
    config.networkConfig = {
      IPv6PrivacyExtensions = false;
    };
  };

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

  services.resolved.settings.Resolve = {
    LLMNR = false;
    MulticastDNS = false;
    Cache = "no-negative";
  };

  networking.getaddrinfo = {
    enable = true;
    # RFC 6724 with increased preference for ULA instead of IPv4
    label = {
      "::1/128" = 0;
      "::/0" = 1;
      "::ffff:0:0/96" = 4;
      "2002::/16" = 2;
      "2001::/32" = 5;
      "fc00::/7" = 13;
      "::/96" = 3;
      "fec0::/10" = 11;
      "3ffe::/16" = 12;
    };
    precedence = {
      "::1/128" = 50;
      "::/0" = 40;
      # ULA preference increased below based on
      # https://datatracker.ietf.org/doc/draft-ietf-6man-rfc6724-update/23/
      "fc00::/7" = 30;
      "::ffff:0:0/96" = 20;
      "2002::/16" = 5;
      "2001::/32" = 5;
      "::/96" = 1;
      "fec0::/10" = 1;
      "3ffe::/16" = 1;
    };
  };

  services.tailscale = {
    openFirewall = lib.mkDefault true;
    disableUpstreamLogging = true;
    useRoutingFeatures = lib.mkDefault "client";
  };

  networking.firewall = {
    trustedInterfaces = [
      "tailscale+"
    ];
  };
}
