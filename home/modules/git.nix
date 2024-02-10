{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
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
      color = {
        ui = true;
        diff-highlight = {
          oldNormal = "red bold";
          oldHighlight = "red bold 52";
          newNormal = "green bold";
          newHighlight = "green bold 22";
        };
        diff = {
          meta = "11";
          frag = "magenta bold";
          func = "146 bold";
          commit = "yellow bold";
          old = "red bold";
          new = "green bold";
          whitespace = "red reverse";
        };
      };
      core = {
        quotePath = false;
      };
      merge.tool = "vimdiff";
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
        sopsdiffer.textconv = "sops -d";
      };
    };
    aliases = {
      bp = "cherry-pick -x";
      co = "commit -v";
      cpa = "cherry-pick --abort";
      cpc = "cherry-pick --continue";
      pfush = "push --force-with-lease --force-if-includes";
    };
    diff-so-fancy = {
      enable = true;
    };
  };

  programs.gitui = {
    enable = true;
    theme = builtins.readFile "${pkgs.vimPlugins.tokyonight-nvim}/extras/gitui/tokyonight_night.ron";
  };
}