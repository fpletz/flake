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
            sha256 = "sha256-zvV+NXmI3df9nHZo3HDRXZ5PPnrNRgrO7wcHfMEh7IA=";
            packages = [
              "luci"
              "luci-app-ddns"
              "luci-proto-wireguard"
              "luci-app-vnstat2"
              "luci-app-sqm"
              "luci-mod-admin-full"
              "luci-mod-rpc"
              "prometheus-node-exporter-lua"
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
