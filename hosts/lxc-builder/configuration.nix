{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    ./buildbot.nix
    ./remote-builders.nix
  ];

  profiles.server.enable = true;

  age.secrets = {
    "lxc-builder/deploy-ssh-key" = { };
  };

  infra = {
    deployer = {
      enable = true;
      sshKeyFile = config.age.secrets."lxc-builder/deploy-ssh-key".path;
    };
    hub.enable = true;
    hubUrl = "http://localhost:${toString config.infra.hub.httpPort}";
  };

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

  infra.deploy.sshKeys = [
    config.me.deployKey
    config.me.wifeKey # anya manages lxc-builder so needs to deploy to it
  ];

  system.stateVersion = "25.11";
}
