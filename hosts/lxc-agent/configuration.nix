{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    ./mcp.nix
    ./netbird.nix
    ./t3.nix
  ];

  profiles.server.enable = true;

  users.groups.agent = { };
  users.users.agent = {
    isSystemUser = true;
    group = "agent";
    home = "/storage-fast/agent";
    createHome = true;
    useDefaultShell = true;
  };

  lxc = {
    enable = true;
    memory = 8192;
    mounts = [
      "/storage-fast/agent,mp=/storage-fast/agent"
    ];
  };

  system.stateVersion = "25.11";
}
