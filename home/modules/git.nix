{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.packages = lib.optionals config.bpletza.workstation.enable [
    pkgs.gitAndTools.tig
    pkgs.git-absorb
  ];

  programs.git = {
    enable = true;
    package = if config.bpletza.workstation.enable then pkgs.git else pkgs.gitMinimal;
    lfs.enable = config.bpletza.workstation.enable;
    maintenance = {
      enable = config.bpletza.workstation.enable;
      repositories = [ "/home/fpletz/src/nixpkgs" ];
    };
    attributes = [
      "*.pdf diff=pdf"
    ];
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
      init.defaultBranch = "main";
      interactive.singleKey = true;
      merge = {
        tool = "vimdiff";
        conflictstyle = "zdiff3";
      };
      blame.date = "short";
      rerere.enabled = true;
      pull.rebase = true;
      fetch = {
        parallel = 0;
        writeCommitGraph = true;
        negotiationAlgorithm = "skipping";
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      checkout = {
        workers = 0;
        thresholdForParallelism = 100;
      };
      rebase = {
        stat = true;
        autoStash = true;
        autoSquash = true;
        updateRefs = true;
        missingCommitsCheck = "warn";
      };
      advice = {
        detachedHead = false;
        statusHints = false;
      };
      pack = {
        allowPackReuse = "multi";
        useBitmapBoundaryTraversal = true;
      };
      maintenance = {
        auto = false;
        strategy = "incremental";
        prefetch.enabled = false;
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
      submodule.fetchJobs = 5;
      http.maxRequests = 10;
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
      recommit = "!git commit -eF $(git rev-parse --git-dir)/COMMIT_EDITMSG";
      blame = "-w -M";
      pr = "!\"pr() { git fetch origin pull/$1/head:pr-$1; git checkout pr-$1; }; pr\"";
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
    enable = config.bpletza.workstation.enable;
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

  xdg.configFile."gitui/theme.ron".source =
    lib.mkForce "${pkgs.vimPlugins.tokyonight-nvim}/extras/gitui/tokyonight_night.ron";

  programs.lazygit = {
    enable = config.bpletza.workstation.enable;
    settings = {
      git = {
        paging = {
          colorArgs = "always";
          pager = "delta --paging=never";
        };
      };
      gui = {
        nerdFontsVersion = "3";
        theme = {
          lightTheme = false;
          activeBorderColor = [
            "#ff9e64"
            "bold"
          ];
          inactiveBorderColor = [ "#27a1b9" ];
          searchingActiveBorderColor = [
            "#ff9e64"
            "bold"
          ];
          optionsTextColor = [ "#7aa2f7" ];
          selectedLineBgColor = [ "#283457" ];
          cherryPickedCommitFgColor = [ "#7aa2f7" ];
          cherryPickedCommitBgColor = [ "#bb9af7" ];
          markedBaseCommitFgColor = [ "#7aa2f7" ];
          markedBaseCommitBgColor = [ "#e0af68" ];
          unstagedChangesColor = [ "db4b4b" ];
          defaultFgColor = [ "#c0caf5" ];
        };
      };
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      inherit (config.programs.git.extraConfig) user;
      signing = {
        behaviour = "own";
        backend = "gpg";
        key = config.programs.git.extraConfig.user.signingkey;
      };
      ui = {
        defaultCommand = "log";
        diff-formatter = "delta";
        show-cryptographic-signatures = true;
      };
      aliases = {
        l = [
          "log"
          "-r"
          "(main..@):: | (main..@)-"
        ];
      };
      templates = {
        duplicate_description = ''
          concat(
            description,
            "\n(cherry picked from commit ",
            commit_id,
            ")"
          )
        '';
      };
    };
  };
}
