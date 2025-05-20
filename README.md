# maeve's nixos config

- `common` - shared configuration for all machines

    - `aarch64-darwin` common configs for macOS computers

    - `x86_64-linux` common configs for x86 Linux computers
        
        - `gnome`, `i3`, `hyprland` - WM & DE configs

            - `pkgs` - WM & DE specific packages

- `hosts` - hardware specific configuration

    - `aarch64-darwin` macOS computers

        - `stainless` - 2021 MacBook Pro work laptop

    - `x86_64-linux` x86 Linux computers

        - `aluminium` - Framework 13 work laptop

        - `elster` - rack-mounted gaming PC

        - `replika` - Framework 13 personal laptop

- `pkgs` - non arch-specific packges

- `secrets` - age encrypted secrets

## flake

`nixosConfigurations` and `darwinConfigurations` are automatically generated and populated. To add a new computer, simply add it in the correct `hosts` subdirectory. `inputs` is passed through to each host's config, so flakes can be added to imports individually.

## install instructions

soon
