{
  programs.nixvim = {
    plugins = {
      comment-nvim = {
        enable = true;
        preHook = "require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()";
      };
      ts-context-commentstring.enable = true;
      todo-comments = {
        enable = true;
        highlight.pattern = ".*<(KEYWORDS)\\s*";
        search.pattern = "\\b(KEYWORDS)\\b";
      };
    };
  };
}
