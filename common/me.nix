{
  lib,
  ...
}:
{
  options.me = {
    username = lib.mkOption { type = lib.types.str; };
    email = lib.mkOption { type = lib.types.str; };
    sshKey = lib.mkOption { type = lib.types.str; };
  };

  config.me = {
    username = "maeve";
    email = "maeve@oa.ke";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDvkX/XN4U6idAnpWO9JbFpKxJFsvGzfmSCCFKIMmpv maeve@oa.ke";
  };
}
