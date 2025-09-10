{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    ./buildbot.nix
    ./attic-watch.nix
  ];

  profiles.server.enable = true;

  lxc = {
    enable = true;
    cores = 10;
    memory = 32768;
    diskSize = 100;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    # anya uses lxc-builder as a remote builder for x86_64-linux stuff
    config.me.wifeKey
  ];

  system.stateVersion = "25.11";
}
