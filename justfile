@_default:
  just --list  --unsorted

# use deploy-rs to update an existing host
[group('deployment')]
@deploy host build='local': _add
    nix run github:serokell/deploy-rs#deploy-rs -- .#{{host}} -s {{ if build == "remote" { "--remote-build" } else { "" } }}

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
