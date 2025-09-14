# maeve's nix config

```
nixos-config
┣━━ assets                      # images and assets
┣━━ hosts                       # host specific configuration
┃   ┣━━ aluminium               # Framework 13
┃   ┣━━ elster                  # desktop gaming PC
┃   ┣━━ melty                   # 2020 MacBook Air (M1)
┃   ┣━━ replika                 # Framework 13
┃   ┣━━ stainless               # 2021 MacBook Pro
┃   ┣━━ lxc-builder             # buildbot LXC
┃   ┣━━ lxc-net-router          # netbird router
┃   ┣━━ lxc-net-router-2        # netbird router (backup)
┃   ┗━━ lxc-share               # SMB & SFTP server
┣━━ modules                     # shared modules
┃   ┗━━ common/darwin/nixos     # platform specific modules
┃       ┗━━ profiles            
┃           ┣━━ server          # for servers
┃           ┗━━ workstation     # for personal workstations
┗━━ secrets                     # age encrypted secrets
```

## flake

`nixosConfigurations` and `darwinConfigurations` are automatically generated and populated. To add a new host, create a new directory within the correct `hosts` subdirectory. `inputs` is passed through to each host's config, so flakes can be imported in host-specific configurations.

## install instructions

soon
