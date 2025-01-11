{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [ treesj ];

  extraConfigLua = ''
    require("treesj").setup({
      use_default_keymap = false,
    })
  '';

  keymaps = [
    {
      mode = "n";
      key = "<leader>tj";
      action.__raw = "require('treesj').join";
    }
    {
      mode = "n";
      key = "<leader>ts";
      action.__raw = "require('treesj').split";
    }
    {
      mode = "n";
      key = "<leader>m";
      action.__raw = "require('treesj').toggle";
    }
    {
      mode = "n";
      key = "<leader>M";
      action.__raw = ''
        function()
          require('treesj').toggle({ split = { recursive = true } })
        end
      '';
    }
  ];
}
