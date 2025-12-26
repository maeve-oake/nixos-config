{
  inputs,
  pkgs,
  hostName,
  config,
  unstable,
  ...
}:
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
    ./attic.nix
  ];

  age.secrets = {
    "lxc-builder/gh-app-key" = { };
    "lxc-builder/gh-webhook-secret" = { };
    "lxc-builder/basic-auth-pwd" = {
      owner = "buildbot";
    };
    "lxc-builder/attic-auth-token" = { };
  };

  services.buildbot-nix.packages = {
    buildbot = unstable.buildbot;
    buildbot-worker = unstable.buildbot-worker;
    buildbot-plugins = unstable.buildbot-plugins;
  };

  services.buildbot-nix.master = {
    enable = true;

    domain = "builder.oa.ke";
    useHTTPS = true;

    workersFile = pkgs.writeText "workers.json" ''
      [
        { "name": "${hostName}", "pass": "its-local-anyway", "cores": 10 }
      ]
    '';

    authBackend = "httpbasicauth";
    httpBasicAuthPasswordFile = config.age.secrets."lxc-builder/basic-auth-pwd".path;
    admins = [
      "maeve-oake"
      "anna-oake"
    ];

    github = {
      enable = true;
      appId = 1885778;
      appSecretKeyFile = config.age.secrets."lxc-builder/gh-app-key".path;
      webhookSecretFile = config.age.secrets."lxc-builder/gh-webhook-secret".path;
      topic = "oake-builder";
    };

    evalWorkerCount = 4;
    evalMaxMemorySize = 4096; # MB per evalWorker

    branches = {
      all-branches = {
        matchGlob = "*";
        registerGCRoots = false;
      };
    };

    attic.targets = {
      buyan = {
        host = "https://attic-buyan.oa.ke";
        cacheName = "nixos";
        authTokenFile = config.age.secrets."lxc-builder/attic-auth-token".path;
        ignoreUpstreamCache = true;
      };
      kitezh = {
        host = "https://attic-kitezh.oa.ke";
        cacheName = "nixos";
        authTokenFile = config.age.secrets."lxc-builder/attic-auth-token".path;
      };
    };
  };

  services.buildbot-nix.worker = {
    enable = true;
    name = hostName;
    workerPasswordFile = pkgs.writeText "worker-password-file" "its-local-anyway";
  };
}
