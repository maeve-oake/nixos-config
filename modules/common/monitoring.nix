{
  config,
  lib,
  ...
}:
{
  age.secrets.metrics-token = lib.mkIf config.monitoring.metrics.enable { };

  monitoring.metrics = {
    namePrefixes = lib.mkBefore [ "buyan" ];
    targetUrl = "https://dash.oa.ke";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8JsBD9HfQ5BYWYZLhAo3SDp06R/tnAJqkKSFKH6g0S";
    tokenFile = config.age.secrets.metrics-token.path;
  };
}
