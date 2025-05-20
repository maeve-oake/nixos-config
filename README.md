# maeve's nixos config

```
nixos-config
┣━━ common                          # shared configuration for all machines
┃   ┣━━ aarch64-darwin              # common configs for nix-darwin hosts
┃   ┗━━ x86_64-linux                # common configs for NixOS hosts
┃       ┗━━ gnome, i3, hyprland     # WM & DE configs 
┃           ┗━━ pkgs                # WM & DE specific packages
┣━━ hosts                           # host specific configuration
┃   ┣━━ aarch64-darwin              # nix-darwin hosts
┃   ┗━━ x86_64-linux                # NixOS hosts
┣━━ pkgs                            # non arch-specific packages
┗━━ secrets                         # age encrypted secrets
```

## flake

`nixosConfigurations` and `darwinConfigurations` are automatically generated and populated. To add a new computer, simply add it in the correct `hosts` subdirectory. `inputs` is passed through to each host's config, so flakes can be added to imports individually.

## install instructions

soon
