{
  keymaps = [
    {
      mode = "n";
      key = "<Leader>;";
      action.__raw = "require('dropbar.api').pick";
      options = {
        desc = "Pick symbols in winbar";
      };
    }
    {
      mode = "n";
      key = "[;";
      action.__raw = "require('dropbar.api').goto_context_start";
      options = {
        desc = "Go to start of current context";
      };
    }
    {
      mode = "n";
      key = "];";
      action.__raw = "require('dropbar.api').select_next_context";
      options = {
        desc = "Select next context";
      };
    }
  ];

  plugins = {
    dropbar = {
      enable = true;
    };
  };
}
