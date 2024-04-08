{ pkgs, ... }:
{
  programs.nixvim = {
    colorschemes.catppuccin.integrations.telescope.enabled = true;

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
        key = "<leader>fh";
        action = "require'telescope'.extensions.harpoon.marks";
        lua = true;
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fp";
        action = "require'telescope'.extensions.projects.projects";
        lua = true;
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fn";
        action = "require'telescope'.extensions.notify.notify";
        lua = true;
        options.silent = true;
      }
      {
        mode = [
          "v"
          "n"
        ];
        key = "<leader>cp";
        action = "require(\"actions-preview\").code_actions";
        lua = true;
      }
      {
        mode = "n";
        key = "<leader>u";
        action = "require('telescope').extensions.undo.undo";
        lua = true;
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
        };
        settings = {
          defaults = {
            winblend = 10;
            mappings =
              let
                open_with_trouble = {
                  __raw = "require(\"trouble.providers.telescope\").open_with_trouble";
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
      harpoon = {
        enable = true;
        enableTelescope = true;
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
