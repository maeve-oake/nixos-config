{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    ./netbird.nix
  ];

  profiles.server.zrepl = {
    enable = true;

    # this is where snapshots replicated by localJob or remoteJobs.pull would be stored on this machine
    dataset = "storage/zrepl";

    # this decides which snapshots to _keep_ during pruning of
    # 1. the original snapshots (post snapshotting job)
    # 2. locally replicated snapshots (post localJob)
    # 3. replicas of remote snapshots (post remoteJobs.pull)
    pruningKeepSchedule = "1x1h(keep=all) | 24x1h | 30x1d | 3x30d";

    snapshotting = {
      datasets = [
        "rpool/storage/kittycraft<"
      ];
      cron = "0 * * * *"; # snapshots will be created on each hour
    };

    localJob = {
      datasets = [
        "rpool/storage/kittycraft<"
      ];
      interval = "30m"; # SSD -> HDD replication of new snapshots every 30 minutes
    };

    # the following doesn't actively do anything,
    # just allows mynah-kitezh to connect and pull snapshots of specified datasets
    remoteJobs.serve = {
      mynah-kitezh = {
        listenAddress = "100.94.222.2:28000";
        clientAddress = "100.94.222.1";
        datasets = [ "rpool/storage/kittycraft<" ];
      };
    };
  };

  lxc = {
    enable = true;
  };

  system.stateVersion = "25.11";
}
