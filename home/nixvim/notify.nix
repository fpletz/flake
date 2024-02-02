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
        topDown = false;
      };
      noice.notify.enabled = true;
    };
  };
}
