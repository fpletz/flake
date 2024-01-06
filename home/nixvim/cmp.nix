{ pkgs, ... }:
{
  programs.nixvim = {
    colorschemes.catppuccin.integrations.cmp = true;

    extraPlugins = with pkgs.vimPlugins; [
      cmp_luasnip
      friendly-snippets
    ];

    plugins = {
      nvim-cmp = {
        enable = true;
        autoEnableSources = false;
        sources = [
          { name = "nvim_lsp"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "path"; }
          { name = "luasnip"; }
          { name = "calc"; }
          { name = "emoji"; }
          { name = "treesitter"; }
          { name = "buffer"; keywordLength = 3; }
          { name = "rg"; keywordLength = 3; }
          { name = "spell"; keywordLength = 3; }
        ];
        mapping = {
          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.abort()";
          "<CR>" = "cmp.mapping.confirm({ select = false })";
        };
        mappingPresets = [ "insert" ];
        snippet.expand = "luasnip";
      };
      cmp-buffer.enable = true;
      cmp-calc.enable = true;
      cmp-cmdline.enable = true;
      cmp-emoji.enable = true;
      cmp-git.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;
      cmp-path.enable = true;
      cmp-rg.enable = true;
      cmp-spell.enable = true;
      cmp-treesitter.enable = true;
      luasnip = {
        enable = true;
        fromVscode = [{ }];
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
          };
        };
      };
    };

    extraConfigLua = ''
      local cmp = require('cmp')
  
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' },
          { name = 'path' },
          { name = 'emoji' },
        }, {
          { name = 'buffer', keyword_length = 3 },
        })
      })
  
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        formatting = {
          fields = { "abbr" },
        },
        sources = {
          { name = 'buffer' }
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
  };
}
