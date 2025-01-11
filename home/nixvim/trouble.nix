{
  keymaps = [
    {
      mode = "n";
      key = "<leader>xx";
      action.__raw = ''
        function() require("trouble").toggle("diagnostics") end
      '';
    }
    {
      mode = "n";
      key = "<leader>xq";
      action.__raw = ''
        function() require("trouble").toggle("quickfix") end
      '';
    }
    {
      mode = "n";
      key = "<leader>xl";
      action.__raw = ''
        function() require("trouble").toggle("loclist") end
      '';
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
}
