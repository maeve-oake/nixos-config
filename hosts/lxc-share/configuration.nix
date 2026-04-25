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
        allowedExtraShares = [
          "media"
          "kittycraft"
        ];
      };
      anna = {
        sshKey = config.me.wifeKey;
        allowedExtraShares = [
          "media"
          "kittycraft"
        ];
      };
    };
    extraShares = {
      "media" = "/storage/media";
      "kittycraft" = "/storage-fast/kittycraft";
    };
  };

  lxc = {
    enable = true;
    recursiveMounts = {
      "/storage" = "/storage";
      "/storage-fast" = "/storage-fast";
    };
  };

  system.stateVersion = "25.11";
}
