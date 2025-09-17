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
    ignores = [ ".direnv" ];
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
      rerere = {
        enabled = true;
        autoUpdate = true;
      };
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
  };

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
      user = { inherit (config.programs.git.extraConfig.user) name email; };
      signing = {
        behaviour = "own";
        backend = "gpg";
        key = config.programs.git.extraConfig.user.signingkey;
      };
      git = {
        sign-on-push = true;
      };
      ui = {
        default-command = "log";
        diff-formatter = "delta";
        show-cryptographic-signatures = true;
      };
      merge-tools = {
        delta = {
          diff-expected-exit-codes = [
            0
            1
          ];
        };
      };
      revset-aliases = {
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
      };
      aliases = {
        l = [
          "log"
          "-r"
          "(main..@):: | (main..@)-"
        ];
        tug = [
          "bookmark"
          "move"
          "--from"
          "closest_bookmark(@-)"
          "--to"
          "@-"
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
        draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };
    };
  };
}
