{ config, pkgs, ... }:
let
  handler = name: {
    inherit name;
    repositories = [
      "maeve-oake/nixos-config"
      "anna-oake/nixos-config"
    ];
    command = [
      "${pkgs.python3}/bin/python3"
      "${./infra-hook.py}"
    ];
  };
in
{
  age.secrets = {
    "lxc-builder/deploy-ssh-key" = { };
    "lxc-builder/github-public-token" = { };
  };
  infra = {
    deployer = {
      enable = true;
      sshKeyFile = config.age.secrets."lxc-builder/deploy-ssh-key".path;
    };
    hub = {
      enable = true;
      githubTokenFile = config.age.secrets."lxc-builder/github-public-token".path;
    };
    hubUrl = "http://localhost:${toString config.infra.hub.httpPort}";
  };
  services.nixbot = {
    evaluationFinished = [ (handler "Infra evaluation inventory") ];
    attributeFinished = [ (handler "dix snapshot and Infra readiness") ];
  };
  users.groups.infra-inbox = { };
  users.users.infra-hub.extraGroups = [ "infra-inbox" ];
  users.users.nixbot.extraGroups = [ "infra-inbox" ];
  systemd.tmpfiles.rules = [
    "d /var/lib/infra-hub 0711 infra-hub infra-hub - -"
    "d /var/lib/infra-hub/inbox 2770 infra-hub infra-inbox - -"
  ];
  systemd.services.infra-hub.serviceConfig.StateDirectoryMode = "0711";
  systemd.services.nixbot.path = [ pkgs.dix ];
  systemd.services.nixbot.serviceConfig.ReadWritePaths = [ "/var/lib/infra-hub/inbox" ];
}
