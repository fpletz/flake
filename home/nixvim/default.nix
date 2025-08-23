{ lib, ... }:
{
  imports = [
    ./barbar.nix
    ./blink-cmp.nix
    ./comment.nix
    ./conform.nix
    ./dial.nix
    ./dropbar.nix
    ./flash.nix
    ./gitsigns.nix
    ./inc-rename.nix
    ./lsp.nix
    ./neogit.nix
    ./numb.nix
    ./snacks.nix
    ./treesitter.nix
    ./treesj.nix
    ./trouble.nix
    ./yanky.nix
  ];

  withRuby = false;

  performance = {
    byteCompileLua = {
      enable = true;
      luaLib = true;
      nvimRuntime = true;
      plugins = true;
    };
  };

  globals = {
    mapleader = " ";
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
    spell = false;
    list = true;
    updatetime = 2000;
    termguicolors = true;
  };

  clipboard = {
    register = "unnamedplus";
  };

  colorscheme = lib.mkForce "tokyonight";
  colorschemes = {
    tokyonight = {
      enable = true;
      settings = {
        style = "night";
        transparent = true;
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>vn";
      action = ":set number! number? relativenumber! relativenumber?<CR>";
      options = {
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
  ];

  plugins = {
    better-escape = {
      enable = true;
    };
    diffview = {
      enable = true;
      enhancedDiffHl = true;
    };
    fidget.enable = true;
    lastplace.enable = true;
    lualine = {
      enable = true;
      settings = {
        globalstatus = true;
        theme = "tokyonight";
      };
    };
    luasnip.enable = true;
    nix.enable = true;
    nix-develop.enable = true;
    markview.enable = true;
    nvim-autopairs = {
      enable = true;
      settings = {
        check_ts = true;
      };
    };
    nvim-surround = {
      enable = true;
    };
    web-devicons.enable = true;
    which-key = {
      enable = true;
    };
  };
}
