{
  programs.nixvim = {
    plugins = {
      comment = {
        enable = true;
        settings.pre_hook = "require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()";
      };
      ts-context-commentstring.enable = true;
      todo-comments = {
        enable = true;
        settings = {
          highlight.pattern = ".*<(KEYWORDS)\\s*";
          search.pattern = "\\b(KEYWORDS)\\b";
        };
      };
    };
  };
}
