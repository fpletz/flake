{ inputs, ... }:
{
  perSystem =
    {
      lib,
      pkgs,
      system,
      self',
      ...
    }:
    let
      opentofu = lib.getExe pkgs.opentofu;
      tfConfiguration = inputs.terranix.lib.terranixConfiguration {
        inherit system;
        modules = [ ./tf/dns.nix ];
      };
    in
    {
      packages.default = tfConfiguration;

      apps = {
        default = self'.apps.apply;

        apply = {
          type = "app";
          program = toString (
            pkgs.writers.writeBash "apply" ''
              if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
              cp ${tfConfiguration} config.tf.json \
                && ${opentofu} init \
                && ${opentofu} apply
            ''
          );
        };

        destroy = {
          type = "app";
          program = toString (
            pkgs.writers.writeBash "destroy" ''
              if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
              cp ${tfConfiguration} config.tf.json \
                && ${opentofu} init \
                && ${opentofu} destroy
            ''
          );
        };
      };
    };
}
