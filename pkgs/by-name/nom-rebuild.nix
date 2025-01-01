{
  lib,
  writers,
  nixos-rebuild-ng,
  nix-output-monitor,
}:
writers.writeBashBin "nom-rebuild" ''
  ${lib.getExe nixos-rebuild-ng} \
    --log-format internal-json -v "$@" \
    |& ${lib.getExe nix-output-monitor} --json
''
