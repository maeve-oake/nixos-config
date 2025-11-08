import? 'shared.just'

@_default: update-shared
  just --list  --unsorted

# update shared.just from oake/nix-things
@update-shared:
  curl -fsSO https://raw.githubusercontent.com/oake/nix-things/refs/heads/main/shared.just

#
#  settings
#
landomain := "lan.ci"
export EDITOR := "nvim"

#
#  personal recipes go below
#

# run nixos-rebuild switch with always-allow-substitutes
[group('tools')]
@rebuild: _add
    sudo nixos-rebuild switch --option always-allow-substitutes true
