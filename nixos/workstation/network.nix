{ config, lib, ... }:
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

    systemd.network.networks = {
      "40-trusted-dhcp" = lib.mkIf (cfg.trustedDHCPInterfaces != [ ]) {
        matchConfig.Name = cfg.trustedDHCPInterfaces;
        linkConfig.RequiredForOnline = false;
        networkConfig = {
          DHCP = true;
          IPv6AcceptRA = true;
          MulticastDNS = true;
          LLDP = true;
          EmitLLDP = true;
          LinkLocalAddressing = "ipv6";
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
      "40-public-uplink" = lib.mkIf (cfg.publicUplinks != [ ]) {
        matchConfig.Name = cfg.publicUplinks;
        linkConfig.RequiredForOnline = false;
        networkConfig = {
          DHCP = true;
          IPv6AcceptRA = true;
          IPv6PrivacyExtensions = true;
          IgnoreCarrierLoss = "5s";
        };
        dhcpV4Config = {
          UseHostname = false;
          RouteMetric = 23;
        };
        dhcpV6Config = {
          UseHostname = false;
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

    services.tailscale.enable = true;
  };
}
