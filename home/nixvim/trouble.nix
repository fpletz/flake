{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>xx";
        action = "function() require(\"trouble\").toggle() end";
        lua = true;
      }
      {
        mode = "n";
        key = "<leader>xw";
        action = "function() require(\"trouble\").toggle(\"workspace_diagnostics\") end";
        lua = true;
      }
      {
        mode = "n";
        key = "<leader>xd";
        action = "function() require(\"trouble\").toggle(\"document_diagnostics\") end";
        lua = true;
      }
      {
        mode = "n";
        key = "<leader>xq";
        action = "function() require(\"trouble\").toggle(\"quickfix\") end";
        lua = true;
      }
      {
        mode = "n";
        key = "<leader>xl";
        action = "function() require(\"trouble\").toggle(\"loclist\") end";
        lua = true;
      }
      {
        mode = "n";
        key = "gR";
        action = "function() require(\"trouble\").toggle(\"lsp_references\") end";
        lua = true;
      }
    ];
    plugins = {
      trouble = {
        enable = true;
        settings = {
          auto_close = true;
        };
      };
    };
  };
}
