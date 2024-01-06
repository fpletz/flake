{
  programs.nixvim = {
    colorschemes.catppuccin.integrations.fidget = true;
    plugins = {
      fidget = {
        enable = true;
      };
      notify = {
        enable = true;
        render = { __raw = "\"compact\""; };
      };
      noice.notify.enabled = true;
    };
  };
}
