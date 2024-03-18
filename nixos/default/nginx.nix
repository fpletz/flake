{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.nginx = {
    package = lib.mkDefault pkgs.nginxMainline;
    recommendedOptimisation = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;
    recommendedGzipSettings = lib.mkDefault true;
    recommendedBrotliSettings = lib.mkDefault true;
    recommendedProxySettings = lib.mkDefault true;
    # set sensible resolvers for ocsp stapling
    resolver.addresses =
      let
        isIPv6 = addr: builtins.match "^[^\\[]*:.*:.*$" addr != null;
        escapeIPv6 = addr: if isIPv6 addr then "[${addr}]" else addr;
        cloudflare = [
          "1.1.1.1"
          "[2606:4700:4700::1111]"
        ];
        resolvers =
          if config.networking.nameservers != [ ] then
            config.networking.nameservers
          else if config.services.resolved.enable then
            [ "127.0.0.53" ]
          else
            cloudflare;
      in
      map escapeIPv6 resolvers;
    logError = "stderr info";
    appendHttpConfig = ''
      log_format json escape=json '{ "time": "$time_iso8601", '
        '"remote_addr": "$remote_addr", '
        '"remote_user": "$remote_user", '
        '"ssl_protocol_cipher": "$ssl_protocol/$ssl_cipher", '
        '"body_bytes_sent": "$body_bytes_sent", '
        '"request_time": "$request_time", '
        '"status": "$status", '
        '"request": "$request", '
        '"request_method": "$request_method", '
        '"http_referrer": "$http_referer", '
        '"http_x_forwarded_for": "$http_x_forwarded_for", '
        '"http_cf_ray": "$http_cf_ray", '
        '"host": "$host", '
        '"server_name": "$server_name", '
        '"upstream_address": "$upstream_addr", '
        '"upstream_status": "$upstream_status", '
        '"upstream_response_time": "$upstream_response_time", '
        '"upstream_response_length": "$upstream_response_length", '
        '"upstream_cache_status": "$upstream_cache_status", '
        '"http_user_agent": "$http_user_agent" }';
      access_log syslog:server=unix:/dev/log,facility=local4,severity=debug,nohostname json;
    '';
  };
}
