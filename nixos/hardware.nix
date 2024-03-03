{
  imports = map (fn: ./hardware + "/${fn}") (builtins.attrNames (builtins.readDir ./hardware));
}
