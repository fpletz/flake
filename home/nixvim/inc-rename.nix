{
  keymaps = [
    {
      mode = "n";
      key = "<leader>rn";
      action.__raw = ''
        function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end
      '';
      options = {
        expr = true;
        desc = "IncRename";
      };
    }
  ];

  plugins.inc-rename.enable = true;
}
