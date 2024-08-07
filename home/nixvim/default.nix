{ lib, config, ... }:
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
    ./noice.nix
    ./notify.nix
    ./numb.nix
    ./telescope.nix
    ./treesitter.nix
    ./treesj.nix
    ./trouble.nix
    ./yanky.nix
  ];

  config.programs.nixvim = {
    enable = config.bpletza.workstation.enable;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    enableMan = false;

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
    };

    clipboard = {
      register = "unnamedplus";
    };

    colorscheme = lib.mkForce "tokyonight";
    colorschemes = {
      catppuccin = {
        enable = true;
        settings = {
          flavour = "mocha";
          integrations = {
            barbar = true;
            harpoon = true;
            indent_blankline.enabled = true;
            noice = true;
            navic.enabled = true;
          };
        };
      };
      dracula.enable = true;
      gruvbox.enable = true;
      melange.enable = true;
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
      barbecue = {
        enable = true;
        theme = "tokyonight";
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
        globalstatus = true;
        theme = "tokyonight";
      };
      nix.enable = true;
      nix-develop.enable = true;
      neo-tree = {
        enable = true;
      };
      project-nvim = {
        enable = true;
        enableTelescope = true;
      };
      nvim-autopairs = {
        enable = true;
        settings = {
          check_ts = true;
        };
      };
      #which-key = {
      #  enable = true;
      #};
      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          open_mapping = "[[<c-\\>]]";
        };
      };
    };
  };
}
