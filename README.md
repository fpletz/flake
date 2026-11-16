# fpletz flake

Nix flake ([flake-parts](https://flake.parts)) with the expressions for my personal infrastructure. Work in progress.

## What's inside

| Path | Contents |
| --- | --- |
| `nixos/modules` | Reusable NixOS modules (`nixosModules.all`) |
| `machines/` | Per-host configurations |
| `home/` | home-manager and nixvim configuration |
| `pkgs/by-name` | Custom packages |
| `openwrt/` | OpenWrt images |
| `tf/`, `tf.nix` | DNS managed via terranix / OpenTofu |
| `secrets/` | sops-nix encrypted secrets |

## Usage

```sh
nix develop                                        # dev shell (sops, nh, nixos-anywhere, treefmt, ...)
nix fmt                                            # format with treefmt
nix run .#check                                    # run all checks (same as CI)
nix run .#apply                                    # generate config.tf.json and apply DNS via tofu
nh os switch .#<host>                              # deploy a machine (use nh, add --target-host for remote)
```

Copy `.env.template` to `.env` for the required environment variables.

## License

See [LICENSE](LICENSE).
