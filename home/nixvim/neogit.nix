{
  keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action.__raw = ''function() require("neogit").open() end'';
      options.silent = true;
    }
    {
      mode = "n";
      key = "<leader>gl";
      action.__raw = ''function() require("neogit").open({"log"}) end'';
      options.silent = true;
    }
    {
      mode = "n";
      key = "<leader>gp";
      action.__raw = ''function() require("neogit").open({"pull"}) end'';
      options.silent = true;
    }
    {
      mode = "n";
      key = "<leader>gP";
      action.__raw = ''function() require("neogit").open({"push"}) end'';
      options.silent = true;
    }
  ];

  plugins.neogit = {
    enable = true;
    settings = {
      graph_style.__raw = ''"kitty"'';
      integrations = {
        telescope = true;
      };
      signs = {
        item = [
          "↪"
          "↓"
        ];
        section = [
          "↪"
          "↓"
        ];
      };
    };
  };
}
