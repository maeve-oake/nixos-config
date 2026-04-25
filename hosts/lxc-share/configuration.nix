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
          "kittycraft-extra"
        ];
      };
      anna = {
        sshKey = config.me.wifeKey;
        allowedExtraShares = [
          "media"
          "kittycraft"
          "kittycraft-extra"
        ];
      };
    };
    extraShares = {
      "media" = "/storage/media";
      "kittycraft" = "/storage-fast/kittycraft";
      "kittycraft-extra" = "/storage/kittycraft-extra";
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
