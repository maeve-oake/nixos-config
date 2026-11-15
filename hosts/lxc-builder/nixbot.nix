{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixbot.nixosModules.nixbot
    ./nixbot-module.nix
    ./attic.nix
    ./infra
  ];

  age.secrets = {
    "lxc-builder/gh-app-key" = { };
    "lxc-builder/gh-webhook-secret" = { };
    "lxc-builder/attic-auth-token" = { };
  };

  services.nixbot = {
    enable = true;
    packages.nixbot = pkgs.nixbot;
    domain = "builder.oa.ke";
    useHTTPS = true;
    proxyAuthHeader = "X-Oake-Username";
    admins = [
      "proxy:anna"
      "proxy:maeve"
    ];
    github = {
      enable = true;
      appId = 1885778;
      appSecretKeyFile = config.age.secrets."lxc-builder/gh-app-key".path;
      webhookSecretFile = config.age.secrets."lxc-builder/gh-webhook-secret".path;
      topic = "oake-builder";
    };
    evalWorkerCount = 6;
    evalMaxMemorySize = 3072;
    branches.all-branches = {
      matchGlob = "*";
      registerGCRoots = false;
    };
  };

  services.nixbot.buildFinished = [
    {
      name = "t3-flake-fixer";
      repositories = [
        "maeve-oake/nixos-config"
        "anna-oake/nixos-config"
      ];
      command = [
        (lib.getExe pkgs.t3-flake-fixer)
        "notify"
        "--url"
        "http://slopster.me.ow:9847/nixbot-failure"
      ];
    }
  ];

  systemd.mounts = [
    {
      what = "proc";
      where = "/run/nixbot-proc";
      type = "proc";
      options = "nosuid,nodev,noexec";
    }
  ];
  systemd.services.nixbot = {
    unitConfig.RequiresMountsFor = [ "/run/nixbot-proc" ];
    serviceConfig.ReadWritePaths = [ "/run/nixbot-proc" ];
  };
}
