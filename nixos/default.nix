{ lib, ... }:
{
  flake.nixosModules = {
    all = {
      imports = lib.filesystem.listFilesRecursive ./modules;
    };
  };
}
