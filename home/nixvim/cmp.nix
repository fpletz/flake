{ ... }:
{
  colorschemes.catppuccin.settings.integrations.cmp = true;

  plugins = {
    cmp = {
      enable = true;
      autoEnableSources = false;
      settings = {
        sources.__raw = ''
          cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lsp_signature_help' },
            { name = 'treesitter' },
            { name = 'path' },
            { name = 'luasnip' },
          }, {
            { name = 'buffer' },
            { name = 'calc' },
            { name = 'emoji' },
            { name = 'cmp_yanky' },
          }, {
            { name = 'spell', keywordLength = 3 },
          })
        '';
        mapping = {
          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.abort()";
          "<CR>" = "cmp.mapping.confirm({ select = false })";
          "<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<C-n>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
        mappingPresets = [ "insert" ];
        snippet.expand = ''
          function(args)
            require('luasnip').lsp_expand(args.body)
          end
        '';
      };
      filetype.gitcommit.sources.__raw = ''
        cmp.config.sources({
          { name = 'git' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
          { name = 'emoji' },
        })
      '';
    };
    cmp-buffer.enable = true;
    cmp-calc.enable = true;
    cmp-cmdline.enable = true;
    cmp-emoji.enable = true;
    cmp-git.enable = true;
    cmp_luasnip.enable = true;
    cmp-nvim-lsp.enable = true;
    cmp-nvim-lsp-document-symbol.enable = true;
    cmp-nvim-lsp-signature-help.enable = true;
    cmp-path.enable = true;
    cmp-rg.enable = true;
    cmp-spell.enable = true;
    cmp-treesitter.enable = true;
    cmp_yanky.enable = true;
    luasnip = {
      enable = true;
      fromVscode = [ { } ];
    };
    lspkind = {
      enable = true;
      cmp = {
        enable = true;
        maxWidth = 50;
        ellipsisChar = "…";
        menu = {
          nvim_lsp = "λ";
          luasnip = "⋗";
          buffer = "Ω";
          path = "";
          rg = "";
          calc = "";
          emoji = "";
          treesitter = "";
          spell = "";
          cmp_yanky = "";
        };
      };
    };
    friendly-snippets.enable = true;
  };

  extraConfigLua = ''
    local cmp = require('cmp')

    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      formatting = {
        fields = { "abbr" },
      },
      sources = {
        { name = 'nvim_lsp_document_symbol' },
      }, {
        { name = 'buffer' },
      },
    })

    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      formatting = {
        fields = { "abbr" },
      },
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      })
    })

    require("cmp_git").setup()

    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done()
    )
  '';
}
