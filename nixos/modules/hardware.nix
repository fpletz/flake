{ lib, ... }:
{
  imports = lib.filesystem.listFilesRecursive ./hardware;
}
