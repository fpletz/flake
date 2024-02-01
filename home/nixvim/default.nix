{ lib, ... }:
{
  imports = [
    ./cmp.nix
    ./dap.nix
    ./gitsigns.nix
    ./inc-rename.nix
    ./lsp.nix
    ./notify.nix
    ./none-ls.nix
    ./telescope.nix
    ./treesitter.nix
    ./treesj.nix
    ./trouble.nix
    ./yanky.nix
  ];
  config.programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    luaLoader.enable = true;
    globals = {
      mapleader = ",";
      loaded_perl_provider = 0;
      loaded_ruby_provider = 0;
    };
    options = {
      expandtab = true;
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 4;
      cursorline = true;
      scrolloff = 5;
      visualbell = true;
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      undofile = true;
      spell = true;
      list = true;
      updatetime = 2000;
      termguicolors = true;
    };
    clipboard = {
      register = "unnamedplus";
    };
    colorscheme = lib.mkForce "catppuccin";
    colorschemes = {
      catppuccin = {
        enable = true;
        flavour = "mocha";
        integrations = {
          barbar = true;
          harpoon = true;
          indent_blankline.enabled = true;
          noice = true;
          navic.enabled = true;
        };
      };
      dracula = {
        enable = true;
      };
      gruvbox = {
        enable = true;
      };
      melange = {
        enable = true;
      };
      tokyonight = {
        enable = true;
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>n";
        action = ":set number! number? relativenumber! relativenumber?<CR>";
        options.silent = true;
      }
      {
        mode = "x";
        key = "<";
        action = "<gv";
      }
      {
        mode = "x";
        key = ">";
        action = ">gv|";
      }
      {
        mode = "n";
        key = "<A-,>";
        action = "<Cmd>BufferPrevious<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<A-.>";
        action = "<Cmd>BufferNext<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<A-<>";
        action = "<Cmd>BufferMovePrevious<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<A->>";
        action = "<Cmd>BufferMoveNext<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<A-c>";
        action = "<Cmd>BufferClose<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<A-p>";
        action = "<Cmd>BufferPin<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-p>";
        action = "<Cmd>BufferPick<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>G";
        action = "<Cmd>Git<CR>";
      }
      {
        mode = "n";
        key = "<Space><Space>";
        action = "<cmd>Neotree toggle<cr>";
        options.silent = true;
      }
    ];
    plugins = {
      auto-session = {
        enable = true;
        sessionLens.loadOnSetup = true;
      };
      barbar.enable = true;
      barbecue = {
        enable = true;
      };
      diffview = {
        enable = true;
        enhancedDiffHl = true;
      };
      comment-nvim = {
        enable = true;
      };
      navic.enable = true;
      indent-blankline.enable = true;
      lastplace.enable = true;
      lualine = {
        enable = true;
        globalstatus = true;
      };
      nix.enable = true;
      nix-develop.enable = true;
      noice = {
        enable = true;
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          inc_rename = true;
          lsp_doc_border = false;
        };
        popupmenu.enabled = true;
        popupmenu.backend = "cmp";
      };
      neo-tree = {
        enable = true;
      };
      project-nvim = {
        enable = true;
      };
      todo-comments = {
        enable = true;
        highlight.pattern = ".*<(KEYWORDS)\\s*";
        search.pattern = "\\b(KEYWORDS)\\b";
      };
      nvim-autopairs = {
        enable = true;
        checkTs = true;
      };
      flash = {
        enable = true;
        modes = {
          char.jumpLabels = true;
        };
      };
      #which-key = {
      #  enable = true;
      #};
      toggleterm = {
        enable = true;
        direction = "float";
        openMapping = "<c-\\>";
      };
    };
  };
}
