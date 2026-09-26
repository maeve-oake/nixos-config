{
  config,
  inputs,
  pkgs,
  ...
}:
let
  packages = config.services.buildbot-nix.packages;

in
{
  services.buildbot-nix.packages.buildbot-nix =
    (packages.python.pkgs.callPackage "${inputs.buildbot-nix}/packages/buildbot-nix.nix" {
      buildbot-gitea = packages.buildbot-gitea;
    }).overrideAttrs
      (old: {
        patches = (old.patches or [ ]) ++ [ ./infra/buildbot-nix.patch ];
        postPatch = (old.postPatch or "") + ''
          cp ${./infra/infra_hooks.py} buildbot_nix/infra_hooks.py
          cp ${./infra/infra_buildbot.py} buildbot_nix/infra_buildbot.py
        '';
      });
  users.groups.infra-inbox = { };
  users.users.infra-hub.extraGroups = [ "infra-inbox" ];
  users.users.buildbot.extraGroups = [ "infra-inbox" ];
  systemd.tmpfiles.rules = [
    "d /var/lib/infra-hub 0711 infra-hub infra-hub - -"
    "d /var/lib/infra-hub/inbox 2770 infra-hub infra-inbox - -"
  ];
  systemd.services.infra-hub.serviceConfig.StateDirectoryMode = "0711";
  systemd.services.buildbot-master.path = [ pkgs.dix-snapshots ];
  systemd.services.buildbot-master.serviceConfig.ReadWritePaths = [
    "/var/lib/infra-hub/inbox"
  ];
}
