{ lib, pkgs, osConfig, ... }:
{
  programs.nixvim = lib.mkIf osConfig.bpletza.workstation.enable {
    colorschemes.catppuccin.integrations.native_lsp.enabled = true;

    extraPlugins = with pkgs.vimPlugins; [
      nvim-surround
    ];

    extraConfigLua = ''
      require("nvim-surround").setup()
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>l";
        action = "require(\"lsp_lines\").toggle";
        lua = true;
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
          dockerls.enable = true;
          gopls.enable = true;
          html.enable = true;
          htmx.enable = true;
          jsonls.enable = true;
          lemminx.enable = true;
          lua-ls.enable = true;
          nil_ls = {
            enable = true;
            extraOptions = {
              formatting.command = "nixpkgs-fmt";
            };
          };
          marksman.enable = true;
          pest_ls.enable = true;
          pyright.enable = true;
          ruff-lsp.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          yamlls.enable = true;
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
        };
      };
      lsp-lines.enable = true;
      lsp-format.enable = true;
      rustaceanvim = {
        enable = true;
        server = {
          standalone = false;
        };
      };
    };
  };
}
