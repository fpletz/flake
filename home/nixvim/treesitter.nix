{ pkgs, ... }:
{
  programs.nixvim = {
    colorschemes.catppuccin.settings.integrations.treesitter = true;

    plugins = {
      treesitter = {
        enable = true;
        nixvimInjections = true;

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          awk
          bash
          bibtex
          c
          cmake
          comment
          commonlisp
          cpp
          css
          csv
          dhall
          diff
          disassembly
          dockerfile
          dot
          dtd
          elixir
          erlang
          fish
          git-config
          git-rebase
          gitcommit
          gitignore
          gleam
          go
          gomod
          gosum
          gotmpl
          graphql
          haskell
          hcl
          helm
          html
          http
          java
          javascript
          json
          json5
          just
          liquidsoap
          lua
          make
          markdown
          markdown-inline
          meson
          ninja
          nix
          objdump
          org
          passwd
          pem
          perl
          php
          printf
          promql
          proto
          python
          regex
          requirements
          robots
          sql
          ssh-config
          strace
          systemtap
          tcl
          terraform
          tmux
          todotxt
          toml
          typescript
          udev
          vim
          vimdoc
          xml
          yaml
          zathurarc
          zig
        ];
        settings = {
          highlight = {
            enable = true;
            additional_vim_regex_highlighting = true;
          };
          indent.enable = true;
          incremental_selection.enable = true;
        };
      };
      treesitter-refactor = {
        enable = true;
        highlightDefinitions.enable = true;
      };
      ts-autotag = {
        enable = true;
      };
    };
  };
}
