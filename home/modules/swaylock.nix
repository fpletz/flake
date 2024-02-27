{ config, ... }:
{
  programs.swaylock = {
    enable = true;
    settings = {
      font = "Fira Sans";
      color = "000000";
      indicator-radius = 240;
      indicator-thickness = 20;
      key-hl-color = "880033";
      separator-color = "00000000";
      inside-color = "00000088";
      inside-clear-color = "ffd20400";
      inside-caps-lock-color = "009ddc00";
      inside-ver-color = "d9d8d800";
      inside-wrong-color = "ee2e2400";
      ring-color = "231f20D9";
      ring-clear-color = "231f20D9";
      ring-caps-lock-color = "231f20D9";
      ring-ver-color = "231f20D9";
      ring-wrong-color = "231f20D9";
      line-color = "00000000";
      line-clear-color = "ffd204FF";
      line-caps-lock-color = "009ddcFF";
      line-ver-color = "d9d8d8FF";
      line-wrong-color = "ee2e24FF";
      text-clear-color = "ffd20400";
      text-ver-color = "d9d8d800";
      text-wrong-color = "ee2e2400";
      bs-hl-color = "ee2e24FF";
      caps-lock-key-hl-color = "ffd204FF";
      caps-lock-bs-hl-color = "ee2e24FF";
      text-caps-lock-color = "009ddc";
    };
  };

  services.swayidle =
    let
      swaylock = "${config.programs.swaylock.package}/bin/swaylock";
      swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
    in
    {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = swaylock;
        }
        {
          event = "lock";
          command = swaylock;
        }
      ];
      timeouts = [
        {
          timeout = 180;
          command = swaylock;
        }
        {
          timeout = 200;
          command = "${swaymsg} 'output * dpms off'";
          resumeCommand = "${swaymsg} 'output * dpms on'";
        }
      ];
    };
}