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
  };

  programs.lazygit = {
    enable = osConfig.bpletza.workstation.enable;
    settings = {
      git = {
        paging = {
          colorArgs = "always";
          pager = "diff-so-fancy";
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
