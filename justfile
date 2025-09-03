@_default:
  just --list  --unsorted

# create/edit agenix secret
[group('secrets')]
@secret secret: _add && rekey
  EDITOR=nano \
  nix run github:oddlama/agenix-rekey -- edit ./secrets/secrets/{{secret}}.age

# rekey all agenix secrets
[group('secrets')]
@rekey: _add
  nix run github:oddlama/agenix-rekey -- rekey -a

# navigate config tree
[group('tools')]
@inspect:
  nix run nixpkgs#nix-inspect -- -p .

@_add:
    git add --all
