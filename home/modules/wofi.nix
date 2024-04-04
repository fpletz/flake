{ lib, config, ... }:
{
  options.bpletza.workstation.wofi = lib.mkOption {
    type = lib.types.bool;
    default = config.bpletza.workstation.sway;
  };

  config = lib.mkIf config.bpletza.workstation.wofi {
    programs.wofi = {
      enable = true;
      settings = {
        insensitive = true;
      };

      style = with config.colorScheme.palette; ''
        body {
          color: #${base05};
        }
        #window {
          border: 1px solid #${base01};
          background-color: #${base00};
          font-family: Inter Display, system-ui, sans-serif;
          font-size: 14px;
        }
        #entry:nth-child(odd) {
          background-color: #${base00};
        }
        #entry:nth-child(even) {
          background-color: #${base01}};
        }
        #entry:selected {
          border-color: #${base0D};
          background-color: #${base02};
          color: #${base04};
        }
        #input {
          border: 1px solid #${base02};
          color: #${base04};
          background-color: #${base01};
        }
        #input:focus {
          border-color: #${base0D};
        }
        #inner-box {
          margin: 0 4px;
          color: #${base05};
        }
        .entry {
          padding: 2px 4px;
        }
      '';
    };
  };
}
