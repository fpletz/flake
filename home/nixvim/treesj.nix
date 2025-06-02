{ ... }:
{
  keymaps = [
    {
      mode = "n";
      key = "<leader>tj";
      action.__raw = "require('treesj').join";
      options.desc = "Block Join";
    }
    {
      mode = "n";
      key = "<leader>ts";
      action.__raw = "require('treesj').split";
      options.desc = "Block Split";
    }
    {
      mode = "n";
      key = "<leader>m";
      action.__raw = "require('treesj').toggle";
      options.desc = "Block Split/Join";
    }
    {
      mode = "n";
      key = "<leader>M";
      action.__raw = ''
        function()
          require('treesj').toggle({ split = { recursive = true } })
        end
      '';
      options.desc = "Recursive Block Split/Join";
    }
  ];

  plugins = {
    treesj = {
      enable = true;
      settings = {
        use_default_keymaps = false;
      };
    };
  };
}
