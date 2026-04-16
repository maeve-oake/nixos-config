{
  config,
  lib,
  ...
}:
{
  age.secrets."lxc-builder/buildbot-ssh-key" = { };

  remoteBuilders.machines = {
    # aarch64-linux
    gratis = {
      enable = true;
      sshUser = "buildbot";
      sshKey = config.age.secrets."lxc-builder/buildbot-ssh-key".path;
    };
    # aarch64-darwin
    fruity = {
      enable = true;
      sshUser = "buildbot";
      sshKey = config.age.secrets."lxc-builder/buildbot-ssh-key".path;
    };
  };

  services.buildbot-nix.master.buildSystems = [
    config.nixpkgs.hostPlatform.system # local build
    "aarch64-linux" # build on gratis
    "aarch64-darwin" # build on fruity
  ];

  age.secrets.netbird-homelab = {
    owner = "netbird";
    group = "netbird";
  };

  services.netbird.simple = {
    enable = true;
    managementUrl = "https://net.oa.ke";
    setupKeyFile = config.age.secrets.netbird-homelab.path;
  };

  services.netbird.clients.default.port = lib.mkForce 31313;
}
