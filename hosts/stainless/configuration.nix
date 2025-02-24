{ pkgs, ... }: {
  imports = [
    ../../common/aarch64-darwin
  ];

  # Do not remove
  system.stateVersion = 5;
}
