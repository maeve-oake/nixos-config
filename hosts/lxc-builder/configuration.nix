{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.lxcModules.default
    ./buildbot.nix
    ./attic-watch.nix
  ];

  lxc = {
    cores = 10;
    memory = 32768;
    diskSize = 100;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    # anya uses lxc-builder as a remote builder for x86_64-linux stuff
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHf6UCNeXSN8WAZ9cXh8jz61+jbP+ts+inct/CCjcN/o anna-oake"
  ];

  system.stateVersion = "25.11";
}
