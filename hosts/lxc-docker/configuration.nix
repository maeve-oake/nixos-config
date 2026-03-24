{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
  ];

  profiles.server.docker = {
    enable = true;
    enableNvidiaSupport = true;

    portainer = {
      enable = true;
      traefikIntegration.entrypoint = "lan";
    };
  };

  lxc = {
    enable = true;
    cores = 10;
    memory = 32768;
    diskSize = 80;
    mounts = [
      "/storage-fast/docker,mp=/var/lib/docker/volumes"
    ];
    recursiveMounts = {
      "/storage" = "/storage";
      "/storage-fast" = "/storage-fast";
    };
    nvidia.enable = true;
  };

  system.stateVersion = "25.11";
}
