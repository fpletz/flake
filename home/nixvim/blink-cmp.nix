{ pkgs, ... }:
{
  extraPlugins = [ pkgs.vimPlugins.blink-cmp-conventional-commits ];

  plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        completion = {
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 500;
          };
          ghost_text = {
            enabled = true;
          };
        };

        sources = {
          default = [
            "lsp"
            "conventional_commits"
            "path"
            "snippets"
            # "markview"
            "emoji"
            "buffer"
            "ripgrep"
          ];
          providers = {
            lsp = {
              fallbacks = [ ];
              score_offset = 10;
            };
            conventional_commits = {
              module = "blink-cmp-conventional-commits";
              name = "Conventional Commits";
              enabled.__raw = ''
                function()
                  return vim.bo.filetype == 'gitcommit'
                end
              '';
              score_offset = 5;
            };
            emoji = {
              module = "blink-emoji";
              name = "Emoji";
              score_offset = 15;
              opts = {
                insert = true;
              };
            };
            ripgrep = {
              async = true;
              module = "blink-ripgrep";
              name = "Ripgrep";
              score_offset = -5;
              opts = {
                prefix_min_len = 3;
                context_size = 5;
                max_filesize = "2M";
                search_casing = "--smart-case";
              };
            };
          };
        };

        snippets = {
          preset = "luasnip";
        };

        signature = {
          enabled = true;
        };
      };
    };
    blink-emoji = {
      enable = true;
    };
    blink-ripgrep = {
      enable = true;
    };
  };
}
