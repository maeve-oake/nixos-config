{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
  ];

  profiles.server.share = {
    enable = true;
    serverString = "Maeve Mynah";
    users = {
      maeve = {
        sshKey = config.me.sshKey;
        allowedExtraShares = [ "media" ];
      };
      anna = {
        sshKey = config.me.wifeKey;
        allowedExtraShares = [ "media" ];
      };
    };
    extraShares = {
      "media" = "/storage/media";
    };
  };

  lxc = {
    enable = true;
    mounts = [
      "/storage,mp=/storage"
    ];
  };

  system.stateVersion = "25.11";
}
