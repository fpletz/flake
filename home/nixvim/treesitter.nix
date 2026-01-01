{ pkgs, ... }:
{
  plugins = {
    treesitter = {
      enable = true;
      nixvimInjections = true;

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        ada
        agda
        awk
        asm
        bash
        bibtex
        bibtex
        c
        caddy
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
        doxygen
        dtd
        ebnf
        editorconfig
        elixir
        elm
        erlang
        fish
        fsh
        git-config
        git-rebase
        gitattributes
        gitcommit
        gitignore
        gleam
        gnuplot
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
        jsonnet
        just
        kcl
        kdl
        latex
        liquidsoap
        lua
        make
        markdown
        markdown-inline
        mermaid
        meson
        muttrc
        ninja
        nix
        ocaml
        ocaml-interface
        objdump
        passwd
        pem
        perl
        php
        po
        printf
        promql
        proto
        python
        regex
        requirements
        robots
        ron
        ruby
        rust
        scala
        scss
        sql
        ssh-config
        strace
        svelte
        systemtap
        terraform
        tmux
        todotxt
        toml
        tsv
        tsx
        twig
        typescript
        typst
        udev
        vala
        vim
        vimdoc
        vue
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
      settings = {
        highlight_definitions.enable = true;
      };
    };
    ts-autotag = {
      enable = true;
    };
  };
}
