{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
  ];

  profiles.server.enable = true;

  age.secrets = {
    "lxc-lancache/steam-token-maeve" = { };
    "lxc-lancache/steam-token-maeve-2" = { };
  };

  services.lancache = {
    enable = true;
    cacheLocation = "/lancache";

    prefill.steam = {
      enable = true;
      accounts = {
        maeve = {
          tokenFile = config.age.secrets."lxc-lancache/steam-token-maeve".path;
          prefillAll = true;
          systems = [
            "windows"
            "linux"
          ];
        };
        maeve-2 = {
          tokenFile = config.age.secrets."lxc-lancache/steam-token-maeve-2".path;
          prefillAll = true;
          systems = [
            "windows"
            "linux"
          ];
        };
      };
    };
  };

  lxc = {
    enable = true;
    mounts = [
      "/storage/lancache,mp=/lancache"
    ];
  };

  system.stateVersion = "25.11";
}
