{ pkgs, ... }:
{
  plugins = {
    treesitter = {
      enable = true;
      nixvimInjections = true;

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        awk
        asm
        bash
        bibtex
        c
        cmake
        comment
        commonlisp
        cpp
        css
        csv
        desktop
        devicetree
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
        gitattributes
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
        ini
        java
        javascript
        jq
        json
        json5
        jsonc
        jsonnet
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
        rust
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
        xcompose
        xresources
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
}
