{
  keymaps = [
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>fy";
      action = "<cmd>YankyRingHistory<cr>";
      options = {
        desc = "Open Yank History";
      };
    }
  ];

  plugins = {
    yanky = {
      enable = true;
    };
  };
}
