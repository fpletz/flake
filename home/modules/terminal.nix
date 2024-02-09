{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "Fira Code";
        size = 10.0;
      };
      scrolling = { history = 20000; };
      window.opacity = 0.95;
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
      live_config_reload = true;
      import = [
        "${pkgs.vimPlugins.tokyonight-nvim}/extras/alacritty/tokyonight_night.toml"
      ];
    };
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()
      config.scrollback_lines = 4000
      config.font = wezterm.font_with_fallback {
        'Fira Code',
        'Noto Color Emoji',
      }
      config.harfbuzz_features = { 'ss02', 'ss04', 'ss05', 'cv19', 'cv23', 'ss09' }
      config.font_size = 10
      config.color_scheme = 'tokyonight_night'
      config.hide_tab_bar_if_only_one_tab = true
      config.check_for_updates = false
      config.visual_bell = {
        fade_in_function = 'EaseIn',
        fade_in_duration_ms = 150,
        fade_out_function = 'EaseOut',
        fade_out_duration_ms = 150,
      }
      config.window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      }
      return config
    '';
  };
}
