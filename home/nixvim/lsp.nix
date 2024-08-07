{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.nixvim = lib.mkIf config.bpletza.workstation.enable {
    colorschemes.catppuccin.settings.integrations.native_lsp.enabled = true;

    extraPlugins = with pkgs.vimPlugins; [ nvim-surround ];

    extraConfigLua = ''
      require("nvim-surround").setup()
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>l";
        action.__raw = "require(\"lsp_lines\").toggle";
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
          dockerls.enable = true;
          gopls.enable = true;
          html.enable = true;
          htmx.enable = true;
          jsonls.enable = true;
          lemminx.enable = true;
          lua-ls.enable = true;
          nixd = {
            enable = true;
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
                  flake-parts.expr = "${localFlake}.debug.options";
                  flake-parts2.expr = "${localFlake}.currentSystem.options";
                };
              };
          };
          marksman.enable = true;
          pest-ls.enable = true;
          pyright.enable = true;
          ruff.enable = true;
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
        settings.server = {
          standalone = false;
          on_attach = "__lspOnAttach";
        };
      };
      typescript-tools = {
        enable = true;
        settings = {
          exposeAsCodeAction = "all";
        };
      };
    };
  };
}
