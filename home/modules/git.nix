{ pkgs, osConfig, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = osConfig.bpletza.workstation.enable;
    extraConfig = {
      user = {
        name = "Franz Pletz";
        email = "fpletz@fnordicwalking.de";
        signingkey = "792617B4";
      };
      url = {
        "git@git.sr.ht:~".insteadOf = "sh:";
        "git@github.com:".insteadOf = "gh:";
      };
      core = {
        quotePath = false;
      };
      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };
      blame.date = "short";
      rerere.enabled = true;
      pull.rebase = true;
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      rebase = {
        stat = true;
        autostash = true;
      };
      commit = {
        gpgsign = true;
        verbose = true;
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
        sopsdiffer.textconv = "sops -d";
      };
      tig = {
        line-graphics = "auto";
        truncation-delimiter = "utf-8";
        color = {
          cursor = "black green bold";
          title-focus = "black blue bold";
          title-blur = "black blue";
        };
      };
    };
    aliases = {
      bp = "cherry-pick -x";
      co = "commit -v";
      cpa = "cherry-pick --abort";
      cpc = "cherry-pick --continue";
      pfush = "push --force-with-lease --force-if-includes";
    };
    delta = {
      enable = true;
      options = {
        dark = true;
        line-numbers = false;
        hyperlinks = true;
      };
    };
    includes = [
      { path = "${pkgs.vimPlugins.tokyonight-nvim}/extras/delta/tokyonight_night.gitconfig"; }
    ];
  };

  programs.gitui = {
    enable = osConfig.bpletza.workstation.enable;
    theme = builtins.readFile "${pkgs.vimPlugins.tokyonight-nvim}/extras/gitui/tokyonight_night.ron";
    keyConfig = ''
      (
        open_help: Some(( code: F(1), modifiers: "")),

        move_left: Some(( code: Char('h'), modifiers: "")),
        move_right: Some(( code: Char('l'), modifiers: "")),
        move_up: Some(( code: Char('k'), modifiers: "")),
        move_down: Some(( code: Char('j'), modifiers: "")),

        popup_up: Some(( code: Char('p'), modifiers: "CONTROL")),
        popup_down: Some(( code: Char('n'), modifiers: "CONTROL")),
        page_up: Some(( code: Char('b'), modifiers: "CONTROL")),
        page_down: Some(( code: Char('f'), modifiers: "CONTROL")),
        home: Some(( code: Char('g'), modifiers: "")),
        end: Some(( code: Char('G'), modifiers: "SHIFT")),
        shift_up: Some(( code: Char('K'), modifiers: "SHIFT")),
        shift_down: Some(( code: Char('J'), modifiers: "SHIFT")),

        edit_file: Some(( code: Char('I'), modifiers: "SHIFT")),

        status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),

        diff_reset_lines: Some(( code: Char('u'), modifiers: "")),
        diff_stage_lines: Some(( code: Char('s'), modifiers: "")),

        stashing_save: Some(( code: Char('w'), modifiers: "")),
        stashing_toggle_index: Some(( code: Char('m'), modifiers: "")),

        stash_open: Some(( code: Char('l'), modifiers: "")),

        abort_merge: Some(( code: Char('M'), modifiers: "SHIFT")),
      )
    '';
  };

  programs.lazygit = {
    enable = osConfig.bpletza.workstation.enable;
    settings = {
      git = {
        paging = {
          colorArgs = "always";
          pager = "delta --paging=never";
        };
      };
      theme = {
        lightTheme = false;
        activeBorderColor = [ "#a6e3a1" "bold" ];
        inactiveBorderColor = [ "#cdd6f4" ]; # Text
        optionsTextColor = [ "#89b4fa" ]; # Blue
        selectedLineBgColor = [ "#313244" ]; # Surface0
        selectedRangeBgColor = [ "#313244" ]; # Surface0
        cherryPickedCommitBgColor = [ "#94e2d5" ]; # Teal
        cherryPickedCommitFgColor = [ "#89b4fa" ]; # Blue
        unstagedChangesColor = [ "red" ]; # Red
      };
    };
  };
}
