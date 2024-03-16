{
  programs.nixvim = {
    plugins = {
      notify = {
        enable = true;
        render = { __raw = "\"compact\""; };
        topDown = false;
      };
      noice.notify.enabled = true;
    };
  };
}
