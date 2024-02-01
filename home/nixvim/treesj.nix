{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      treesj
    ];

    extraConfigLua = ''
      require("treesj").setup({
        use_default_keymap = false,
      })
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>tj";
        action = "require('treesj').join";
        lua = true;
      }
      {
        mode = "n";
        key = "<leader>ts";
        action = "require('treesj').split";
        lua = true;
      }
      {
        mode = "n";
        key = "<leader>m";
        action = "require('treesj').toggle";
        lua = true;
      }
      {
        mode = "n";
        key = "<leader>M";
        action = ''
          function()
            require('treesj').toggle({ split = { recursive = true } })
          end
        '';
        lua = true;
      }
    ];
  };
}
