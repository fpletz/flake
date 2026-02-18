{ lib, config, ... }:
{
  variable.hcloud_token = {
    sensitive = true;
  };

  provider.hcloud = {
    token = "\${var.hcloud_token}";
  };

  resource.hcloud_zone.geht = {
    name = "geht.jetzt";
    mode = "primary";
    ttl = 600;
    delete_protection = false;
  };

  resource.hcloud_zone_rrset.example = {
    zone = config.resource.hcloud_zone.geht.name;
    name = "www.dns";
    type = "AAAA";
    ttl = 600;
    records = [
      {
        value = "::1";
        comment = "web server";
      }
    ];
    change_protection = false;
  };
}
