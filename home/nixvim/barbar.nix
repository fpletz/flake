{
  keymaps = [
    {
      mode = "n";
      key = "<A-,>";
      action = "<Cmd>BufferPrevious<CR>";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<A-.>";
      action = "<Cmd>BufferNext<CR>";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<A-<>";
      action = "<Cmd>BufferMovePrevious<CR>";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<A->>";
      action = "<Cmd>BufferMoveNext<CR>";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<A-c>";
      action = "<Cmd>BufferClose<CR>";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<A-p>";
      action = "<Cmd>BufferPin<CR>";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<C-p>";
      action = "<Cmd>BufferPick<CR>";
      options.silent = true;
    }
  ];

  plugins = {
    barbar.enable = true;
  };
}
