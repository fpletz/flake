{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>rn";
        action = ''
          function()
            return ":IncRename " .. vim.fn.expand("<cword>")
          end
        '';
        lua = true;
        options.expr = true;
      }
    ];

    plugins.inc-rename.enable = true;
  };
}
