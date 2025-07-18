{
  keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action.__raw = ''function() require("neogit").open() end'';
      options = {
        silent = true;
        desc = "Neogit";
      };
    }
    {
      mode = "n";
      key = "<leader>gl";
      action.__raw = ''function() require("neogit").open({"log"}) end'';
      options = {
        silent = true;
        desc = "Neogit log";
      };
    }
    {
      mode = "n";
      key = "<leader>gp";
      action.__raw = ''function() require("neogit").open({"pull"}) end'';
      options = {
        silent = true;
        desc = "Neogit pull";
      };
    }
    {
      mode = "n";
      key = "<leader>gP";
      action.__raw = ''function() require("neogit").open({"push"}) end'';
      options = {
        silent = true;
        desc = "Neogit push";
      };
    }
  ];

  plugins.neogit = {
    enable = true;
    settings = {
      graph_style.__raw = ''"kitty"'';
      integrations = {
        snacks = true;
        diffview = true;
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
