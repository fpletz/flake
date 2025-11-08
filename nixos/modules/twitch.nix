{ config, lib, ... }:

let
  cfg = config.bpletza.twitch;
in
{
  options = {
    bpletza.twitch = {
      enable = lib.mkEnableOption "bpletza streaming";
      webrtcInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "lo" ];
        description = "Interfaces to announce and listen for WebRTC connections";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.mediamtx = {
      enable = true;
      allowVideoAccess = false;
      settings = {
        writeQueueSize = 32768;
        api = true;
        apiAddress = "[::1]:9997";
        metrics = true;
        metricsAddress = "[::1]:9998";

        rtsp = true;
        rtspAddress = "[::]:8554";
        rtspsAddress = "[::]:8322";
        rtpAddress = "[::]:8000";
        rtcpAddress = "[::]:8001";
        protocols = [
          "udp"
          "tcp"
        ];

        rtmp = true;
        rtmpAddress = "[::]:1935";
        rtmpsAddress = "[::]:1936";

        hls = true;
        hlsAddress = "[::]:8888";
        hlsAlwaysRemux = true;
        hlsVariant = "lowLatency";
        hlsSegmentCount = 15;
        hlsSegmentDuration = "1s";
        hlsPartDuration = "200ms";
        hlsAllowOrigin = "*";
        hlsTrustedProxies = [
          "::1"
          "127.0.0.1"
        ];

        webrtc = true;
        webrtcAddress = "[::]:8889";
        webrtcAllowOrigin = "*";
        webrtcTrustedProxies = [ ];
        webrtcLocalUDPAddress = ":8189";
        webrtcICEServers2 = [ ];
        webrtcIPsFromInterfaces = true;
        webrtcIPsFromInterfacesList = cfg.webrtcInterfaces;

        srt = true;
        srtAddress = "[::]:8890";

        paths.all_others.source = "publisher";
      };
    };
  };
}
