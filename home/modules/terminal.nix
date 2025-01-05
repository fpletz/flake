{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.bpletza.workstation.terminal = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.bpletza.workstation.sway;
    };

    default = lib.mkOption {
      type = lib.types.str;
      default = lib.getExe pkgs.ghostty;
    };
  };

  config = lib.mkIf config.bpletza.workstation.terminal.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal.family = "CommitMono";
          size = 10.0;
        };
        scrolling = {
          history = 20000;
        };
        hints = {
          enabled = [
            {
              regex = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`]+";
              command = "xdg-open";
              post_processing = true;
              mouse = {
                enabled = true;
                mods = "None";
              };
              binding = {
                key = "U";
                mods = "Control|Shift";
              };
            }
          ];
        };
        general = {
          import = [ "${pkgs.vimPlugins.tokyonight-nvim}/extras/alacritty/tokyonight_night.toml" ];
          live_config_reload = true;
        };
      };
    };

    home.packages = [ pkgs.ghostty ];

    home.file.".config/ghostty/config".text = ''
      theme = tokyonight
      font-family = "CommitMono"
      font-feature = ss01
      font-feature = ss02
      font-feature = ss03
      font-feature = ss04
      font-feature = ss05
      font-feature = cv08
      font-size = 10
      background-opacity = 0.8
      mouse-hide-while-typing = true
      gtk-adwaita = false
      auto-update = off
      gtk-titlebar = false
      gtk-single-instance = true
      shell-integration = none
      linux-cgroup = always
    '';
  };
}
