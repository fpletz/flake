{ lib, ... }:
{
  imports = [
    ./barbar.nix
    ./cmp.nix
    ./comment.nix
    ./dap.nix
    ./dial.nix
    ./flash.nix
    ./gitsigns.nix
    ./inc-rename.nix
    ./lsp.nix
    ./neogit.nix
    ./noice.nix
    ./notify.nix
    ./numb.nix
    ./telescope.nix
    ./treesitter.nix
    ./treesj.nix
    ./trouble.nix
    ./yanky.nix
  ];

  luaLoader.enable = true;

  globals = {
    mapleader = ",";
    loaded_perl_provider = 0;
    loaded_ruby_provider = 0;
    timeoutlen = 500;
  };

  opts = {
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
    sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions";
  };

  clipboard = {
    register = "unnamedplus";
  };

  colorscheme = lib.mkForce "tokyonight";
  colorschemes = {
    catppuccin = {
      enable = true;
      lazyLoad.enable = true;
      settings = {
        flavour = "mocha";
        integrations = {
          barbar = true;
          indent_blankline.enabled = true;
          noice = true;
          navic.enabled = true;
        };
      };
    };
    tokyonight = {
      enable = true;
      settings.style = "night";
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>n";
      action = ":set number! number? relativenumber! relativenumber?<CR>";
      options = {
        silent = true;
        desc = "Toggle line numbers";
      };
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
      key = "<Space><Space>";
      action = "<cmd>Neotree toggle<cr>";
      options.silent = true;
    }
  ];

  plugins = {
    auto-session = {
      enable = true;
      settings = {
        session_lens.load_on_setup = true;
      };
    };
    barbecue = {
      enable = true;
      settings.theme = "tokyonight";
    };
    better-escape = {
      enable = true;
    };
    diffview = {
      enable = true;
      enhancedDiffHl = true;
    };
    navic.enable = true;
    indent-blankline.enable = true;
    lastplace.enable = true;
    lualine = {
      enable = true;
      settings = {
        globalstatus = true;
        theme = "tokyonight";
      };
    };
    nix.enable = true;
    nix-develop.enable = true;
    neo-tree = {
      enable = true;
    };
    markview.enable = true;
    nvim-autopairs = {
      enable = true;
      settings = {
        check_ts = true;
      };
    };
    project-nvim = {
      enable = true;
      enableTelescope = true;
    };
    toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        open_mapping = "[[<c-\\>]]";
      };
    };
    web-devicons.enable = true;
    which-key = {
      enable = true;
    };
  };
}
