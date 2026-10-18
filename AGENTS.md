# AGENTS.md

Personal Nix flake (flake-parts) for infra: NixOS modules, home-manager, custom pkgs, OpenWrt images, terranix DNS. VCS is jj/git colocated.

## Layout
- `flake.nix` only wires inputs and imports `./pkgs ./openwrt ./machines ./home ./nixos ./treefmt.nix ./tf.nix`.
- `nixos/modules`: reusable modules (exposed as `nixosModules.all`); `home/modules`, `home/nixvim`: home-manager.
- `machines/*.nix`: per-host configs. `nixosConfigurations` in `machines/default.nix` (e.g. `server`) are test-only, not deployed (see FIXME).
- `pkgs/by-name`: custom packages (auto-discovered by-name layout).
- `tf/dns.nix` + `tf.nix`: terranix -> `config.tf.json`.
- `secrets/`, `secrets.yaml`, `.sops.yaml`: sops-nix; never print or commit decrypted secrets. `.env` is gitignored (template: `.env.template`).

## Commands
- Enter shell: `nix develop` (direnv `use flake` + `.env`). Provides sops, nix-fast-build, nixos-anywhere, nh, treefmt.
- Full check (same as CI): `nix run .#check` (wraps `nix-fast-build --no-nom --no-download`; extra args pass through)
- Deploy machines with `nh os switch .#<host>` (add `--target-host <host>` for remote); real hosts: ananas, hal, fpine, trolovo, lolnovo, zocknix.
- Update inputs: `nix run .#update [-- input...]` (runs `nix flake update` and commits `flake.lock` with a conventional message; never use `--commit-lock-file`).
- Format: `nix fmt` (treefmt; pre-commit runs `treefmt --fail-on-change`).
- Terraform: `nix run .#apply` / `.#destroy` (copies generated `config.tf.json`, runs tofu init + apply interactively). Don't run apply without being asked.

## Notes
- `.pre-commit-config.yaml`, `config.tf.json`, `result*`, `.terraform*` are generated/ignored; don't edit.
- nixpkgs is `nixos-unstable-small`; most inputs `follows` nixpkgs, so keep that when adding inputs.
- Commits must follow Conventional Commits (`type(scope): subject`); enforced by a commitlint-rs commit-msg hook (`.commitlintrc.yml`), installed on `nix develop`.
- New files must be `git add`ed (or tracked by jj) to be visible to flake evaluation.
