{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.self.lxcModules.default
  ];

  lxc.profiles.share = {
    enable = true;
    serverString = "Maeve Mynah";
    users = {
      maeve = {
        sshKey = config.me.sshKey;
      };
      anna = {
        sshKey = config.me.wifeKey;
      };
    };
  };

  lxc.mounts = [
    "/storage,mp=/storage"
  ];

  system.stateVersion = "25.11";
}
