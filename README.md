# maeve's nix config

```
nixos-config
┣━━ common                          # common modules for all hosts
┃   ┣━━ aarch64-darwin              # modules for nix-darwin hosts
┃   ┗━━ x86_64-linux                # modules for NixOS hosts
┃       ┗━━ gnome, i3, hyprland     # WM & DE modules 
┣━━ hosts                           # host specific configuration
┃   ┣━━ aarch64-darwin              # nix-darwin hosts
┃   ┗━━ x86_64-linux                # NixOS hosts
┣━━ pkgs                            # package derivations
┗━━ secrets                         # age encrypted secrets
```

## flake

`nixosConfigurations` and `darwinConfigurations` are automatically generated and populated. To add a new host, create a new directory within the correct `hosts` subdirectory. `inputs` is passed through to each host's config, so flakes can be imported in host-specific configurations.

## install instructions

soon
