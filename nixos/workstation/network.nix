{
  config,
  lib,
  ...
}:
let
  cfg = config.bpletza.workstation.network;
in
{
  options.bpletza.workstation.network = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.bpletza.workstation.enable;
      description = "workstation networking";
    };

    trustedDHCPInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "en*" ];
      description = ''
        Trusted Uplinks
      '';
    };

    trustedWifis = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "٩(̾●̮̮̃̾•̃̾)۶" ];
      description = ''
        Trusted Wifi SSIDs on public uplinks
      '';
    };

    publicUplinks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wl*" ];
      description = ''
        Public Uplinks
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.useDHCP = false;

    systemd.network.config = {
      dhcpV4Config = {
        DUIDType = "link-layer";
      };
      dhcpV6Config = {
        DUIDType = "link-layer";
      };
    };

    systemd.network.wait-online = {
      timeout = 10;
      anyInterface = true;
    };

    systemd.network.networks =
      let
        trustedNetworkConfig = {
          networkConfig = {
            DHCP = true;
            IPv6AcceptRA = true;
            MulticastDNS = true;
            LLDP = true;
            EmitLLDP = true;
            LinkLocalAddressing = "ipv6";
            DNSOverTLS = false;
          };
          dhcpV4Config = {
            UseHostname = true;
            UseDNS = true;
            UseNTP = true;
            RouteMetric = 5;
          };
          dhcpV6Config = {
            UseHostname = true;
            UseDNS = true;
            UseNTP = true;
            RouteMetric = 5;
          };
          ipv6AcceptRAConfig = {
            RouteMetric = 5;
          };
        };
      in
      {
        "40-trusted-dhcp" = lib.mkIf (cfg.trustedDHCPInterfaces != [ ]) (
          {
            matchConfig.Name = cfg.trustedDHCPInterfaces;
          }
          // trustedNetworkConfig
        );
        "41-trusted-wifi-uplinks" = lib.mkIf (cfg.publicUplinks != [ ] && cfg.trustedWifis != [ ]) (
          {
            matchConfig = {
              Name = cfg.publicUplinks;
              SSID = cfg.trustedWifis;
            };
          }
          // trustedNetworkConfig
        );
        "50-public-uplink" = lib.mkIf (cfg.publicUplinks != [ ]) {
          matchConfig.Name = cfg.publicUplinks;
          networkConfig = {
            DHCP = true;
            IPv6AcceptRA = true;
            LinkLocalAddressing = "ipv6";
            IPv6PrivacyExtensions = true;
            IPv6LinkLocalAddressGenerationMode = "random";
            DNSDefaultRoute = false;
            DNSOverTLS = false;
          };
          dhcpV4Config = {
            UseHostname = false;
            SendHostname = false;
            RouteMetric = 23;
          };
          dhcpV6Config = {
            UseHostname = false;
            SendHostname = false;
            RouteMetric = 23;
          };
          ipv6AcceptRAConfig = {
            RouteMetric = 23;
          };
        };
      };

    sops.secrets = lib.mkIf config.networking.wireless.enable {
      wifi = { };
    };

    networking.wireless = {
      allowAuxiliaryImperativeNetworks = true;
      secretsFile = config.sops.secrets.wifi.path;
      networks = {
        "٩(̾●̮̮̃̾•̃̾)۶" = {
          pskRaw = "ext:psk_٩(̾●̮̮̃̾•̃̾)۶";
          priority = 42;
        };
        mobilpletz = {
          pskRaw = "ext:psk_mobilpletz";
          priority = 42;
        };
        muccc = {
          pskRaw = "ext:psk_muccc";
          priority = 23;
        };
        echelon = {
          pskRaw = "ext:psk_echelon";
          priority = 5;
        };
        "muenchen.freifunk.net/muc_cty" = {
          priority = 21;
        };
        "WIFIonICE" = {
          priority = 5;
        };
        "" = {
          priority = 1;
          extraConfig = ''
            disabled=1
          '';
        };
      };
    };

    services.tailscale = {
      enable = true;
      openFirewall = true;
    };

    services.avahi = {
      enable = lib.mkDefault true;
      ipv4 = true;
      ipv6 = true;
    };

    networking.firewall = {
      allowedUDPPorts = lib.optional config.services.avahi.enable 5353;
      trustedInterfaces = [
        "podman+"
        "virbr+"
      ];
    };

    networking.wireless = {
      extraConfig = ''
        preassoc_mac_addr=1
        mac_addr=1
        p2p_disabled=1
        passive_scan=1
        fast_reauth=1
      '';
      fallbackToWPA2 = false;
      userControlled.enable = true;
    };
  };
}
