{ lib, pkgs, ... }:
{
  extraConfigLua = # Lua
    ''
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })

      vim.api.nvim_create_user_command("FormatToggle", function()
        if args.bang then
          vim.b.disable_autoformat = not vim.b.disable_autoformat
        else
          vim.g.disable_autoformat = not vim.g.disable_autoformat
        end
      end, {
        desc = "Toggle autoformat-on-save",
        bang = true,
      })
    '';

  keymaps = [
    {
      mode = "n";
      key = "<leader>=";
      action = ":FormatToggle<cr>";
      options.desc = "Toggle format-on-save";
    }
  ];

  plugins = {
    conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          nix = [ "nixfmt" ];
          lua = [ "stylua" ];
          json = [ "jq" ];
          python = [ "ruff_format" ];
          rust = [ "rustfmt" ];
          c = [ "clang_format" ];
          cpp = [ "clang_format" ];
          bash = [ "shfmt" ];
          "_" = [
            "trim_newlines"
            "trim_whitespace"
          ];
        };
        formatters = {
          clang_format.command = lib.getExe' pkgs.clang-tools "clang-format";
          stylua.command = lib.getExe pkgs.stylua;
          shfmt.command = lib.getExe pkgs.shfmt;
        };
        format_on_save = # Lua
          ''
            function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
              end
              return { timeout_ms = 500, lsp_format = "fallback" }
             end
          '';
        default_format_opts = {
          lsp_format = "fallback";
        };
      };
    };
  };
}
