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
        sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHf6UCNeXSN8WAZ9cXh8jz61+jbP+ts+inct/CCjcN/o";
      };
    };
  };

  lxc.mounts = [
    "/storage,mp=/storage"
  ];

  system.stateVersion = "25.11";
}
