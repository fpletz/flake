{
  keymaps = [
    {
      mode = "n";
      key = "<leader>xx";
      action.__raw = ''
        function() require("trouble").toggle("diagnostics") end
      '';
      options.desc = "Trouble diagnostics";
    }
    {
      mode = "n";
      key = "<leader>xq";
      action.__raw = ''
        function() require("trouble").toggle("quickfix") end
      '';
      options.desc = "Trouble quickfix";
    }
    {
      mode = "n";
      key = "<leader>xl";
      action.__raw = ''
        function() require("trouble").toggle("loclist") end
      '';
      options.desc = "Trouble loclist";
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
