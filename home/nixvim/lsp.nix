{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.nixvim = lib.mkIf config.bpletza.workstation.enable {
    colorschemes.catppuccin.settings.integrations.native_lsp.enabled = true;

    extraPlugins = with pkgs.vimPlugins; [
      nvim-surround
      pest-vim
    ];

    extraConfigLua = ''
      require("nvim-surround").setup()
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>l";
        action.__raw = ''
          function()
            vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines, virtual_text = vim.diagnostic.config().virtual_lines })
          end
        '';
      }
      {
        mode = "n";
        key = "<leader>L";
        action.__raw = ''
          function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end
        '';
      }
      {
        mode = "n";
        key = "<leader>=";
        action = ":FormatToggle<cr>";
      }
    ];

    plugins = {
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          clangd.enable = true;
          cmake.enable = true;
          cssls.enable = true;
          docker_compose_language_service.enable = true;
          dockerls.enable = true;
          gopls.enable = true;
          html.enable = true;
          htmx.enable = true;
          jsonls.enable = true;
          lemminx.enable = true;
          lexical.enable = true;
          lua_ls.enable = true;
          nixd = {
            enable = true;
            extraOptions = {
              offset_encoding = "utf-8";
            };
            settings =
              let
                localFlake = ''(builtins.getFlake "/home/fpletz/src/flake")'';
              in
              {
                nixpkgs.expr = "import <nixpkgs> {}";
                formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
                options = {
                  nixos.expr = "${localFlake}.nixosConfigurations.server.options";
                  home-manager.expr = "${localFlake}.homeConfigurations.fpletz.options";
                };
              };
          };
          marksman.enable = true;
          pest_ls = {
            enable = true;
            onAttach.function = ''
              require("pest-vim").setup()
            '';
          };
          pyright.enable = true;
          ruff.enable = true;
          taplo.enable = true;
          texlab.enable = true;
          typos_lsp.enable = true;
          yamlls.enable = true;
          zls.enable = true;
        };
        keymaps = {
          diagnostic = {
            "<leader>j" = "goto_next";
            "<leader>k" = "goto_prev";
          };
          lspBuf = {
            K = "hover";
            "<C-k>" = "signature_help";
            gD = "references";
            gd = "definition";
            gi = "implementation";
            gt = "type_definition";
            rn = "rename";
            ca = "code_action";
          };
          silent = true;
          extra = [
            {
              action.__raw = "function() require('telescope.builtin').lsp_references() end";
              key = "gD";
            }
            {
              action.__raw = "function() require('telescope.builtin').lsp_definitions() end";
              key = "gd";
            }
            {
              action.__raw = "function() require('telescope.builtin').lsp_implementations() end";
              key = "gi";
            }
            {
              action.__raw = "function() require('telescope.builtin').lsp_type_definitions() end";
              key = "gt";
            }
          ];
        };
      };
      lsp-lines.enable = true;
      lsp-format.enable = true;
      rustaceanvim = {
        enable = true;
        settings.server = {
          standalone = false;
        };
      };
      typescript-tools = {
        enable = true;
        settings.settings = {
          expose_as_code_action = "all";
        };
      };
    };
  };
}
