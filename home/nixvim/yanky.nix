{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>fy";
        action = "<cmd>Telescope yank_history<cr>";
        options.silent = true;
      }
    ];

    plugins = {
      yanky = {
        enable = true;
        picker.telescope = {
          enable = true;
        };
      };
    };
  };
}
