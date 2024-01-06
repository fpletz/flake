{ pkgs, ... }:
{
  programs.nixvim = {
    colorschemes.catppuccin.integrations.native_lsp.enabled = true;

    extraPlugins = with pkgs.vimPlugins; [
      rustaceanvim
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
          bashls = {
            enable = true;
          };
          clangd = {
            enable = true;
          };
          dockerls = {
            enable = true;
          };
          jsonls = {
            enable = true;
          };
          nil_ls = {
            enable = true;
          };
          pyright = {
            enable = true;
            installLanguageServer = false;
          };
          ruff-lsp = {
            enable = true;
          };
          gopls = {
            enable = true;
          };
          lua-ls = {
            enable = true;
          };
          yamlls = {
            enable = true;
          };
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
    };
  };
}
