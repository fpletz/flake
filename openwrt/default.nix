{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages =
        let
          openwrt-lib = inputs.openwrt-imagebuilder.lib;
          profiles = openwrt-lib.profiles { inherit pkgs; };
          buildOpenwrtImage = profile: config: openwrt-lib.build (profiles.identifyProfile profile // config);
        in
        {
          router = buildOpenwrtImage "cudy_x6-v1" {
            release = "snapshot";
            sha256 = "sha256-yyeKu5xoaEM2Lpn+n+alrQoFt5sqZktJMUqSwwA3geo=";
            packages = [
              "luci"
              "luci-ssl-openssl"
              "luci-mod-admin-full"
              "luci-mod-rpc"
              "luci-proto-wireguard"
              "luci-app-vnstat2"
              "luci-app-sqm"
              "luci-app-uhttpd"
              "wpad-openssl"
              "luci-app-acme"
              "acme-acmesh-dnsapi"
              "luci-app-ddns"
              "drill"
              "prometheus-node-exporter-lua"
              "prometheus-node-exporter-lua-hostapd_stations"
              "prometheus-node-exporter-lua-hwmon"
              "prometheus-node-exporter-lua-nat_traffic"
              "prometheus-node-exporter-lua-netstat"
              "prometheus-node-exporter-lua-openwrt"
              "prometheus-node-exporter-lua-wifi"
              "prometheus-node-exporter-lua-wifi_stations"
              "tcpdump"
              "htop"
            ];
          };
        };
    };
}
