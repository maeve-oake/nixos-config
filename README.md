# maeve's nix config

```
nixos-config
┣━━ common                          # common modules for all hosts
┃   ┣━━ darwin                      # modules for nix-darwin hosts
┃   ┗━━ nixos                       # modules for NixOS hosts
┣━━ hosts                           # host specific configuration
┃   ┣━━ darwin                      # nix-darwin hosts
┃   ┃   ┗━━ stainless               # 2021 MacBook Pro
┃   ┗━━ nixos                       # NixOS hosts
┃       ┣━━ aluminium               # Framework 13
┃       ┣━━ elster                  # desktop gaming PC
┃       ┣━━ melty                   # 2020 MacBook Air (M1)
┃       ┗━━ replika                 # Framework 13
┣━━ pkgs                            # package derivations
┗━━ secrets                         # age encrypted secrets
```

## flake

`nixosConfigurations` and `darwinConfigurations` are automatically generated and populated. To add a new host, create a new directory within the correct `hosts` subdirectory. `inputs` is passed through to each host's config, so flakes can be imported in host-specific configurations.

## install instructions

soon
