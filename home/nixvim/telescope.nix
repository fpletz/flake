{ pkgs, ... }:
{
  programs.nixvim = {
    colorschemes.catppuccin.settings.integrations.telescope.enabled = true;

    extraPlugins = with pkgs.vimPlugins; [
      telescope-symbols-nvim
      telescope-ui-select-nvim
      actions-preview-nvim
    ];

    keymaps = [
      {
        mode = "n";
        key = "<leader>ft";
        action = "<cmd>Telescope<cr>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fp";
        action.__raw = "require'telescope'.extensions.projects.projects";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fn";
        action.__raw = "require'telescope'.extensions.notify.notify";
        options.silent = true;
      }
      {
        mode = [
          "v"
          "n"
        ];
        key = "<leader>cp";
        action.__raw = "require(\"actions-preview\").code_actions";
      }
      {
        mode = "n";
        key = "<leader>u";
        action.__raw = "require('telescope').extensions.undo.undo";
      }
    ];

    plugins = {
      telescope = {
        enable = true;
        enabledExtensions = [
          "notify"
          "ui-select"
        ];
        extensions = {
          fzf-native.enable = true;
          undo.enable = true;
        };
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fc" = "colorscheme";
          "<leader>fs" = "symbols";
          "<leader>fr" = "resume";
          "<leader>fq" = "quickfix";
          "<leader>fd" = "diagnostics";
        };
        settings = {
          defaults = {
            winblend = 10;
            mappings =
              let
                open_with_trouble = {
                  __raw = "require(\"trouble.sources.telescope\").open";
                };
              in
              {
                i = {
                  "<c-t>" = open_with_trouble;
                };
                n = {
                  "<c-t>" = open_with_trouble;
                };
              };
          };
          extensions = {
            ui-select = {
              __raw = "require'telescope.themes'.get_dropdown()";
            };
            notify = {
              layout_strategy = "";
            };
          };
        };
      };
    };

    extraConfigLua = ''
      require("actions-preview").setup {
        diff = {
          algorithm = "histogram",
        },
        telescope = {
          sorting_strategy = "ascending",
          layout_strategy = "vertical",
          layout_config = {
            width = 0.8,
            height = 0.9,
            prompt_position = "top",
            preview_cutoff = 17,
            preview_height = function(_, _, max_lines)
              return max_lines - 13
            end,
          },
        },
      }
    '';
  };
}
