{
  lib,
  pkgs,
  ...
}:
{
  services.t3-server = {
    enable = true;
    user = "agent";
    group = "agent";
    lan = true;
    browserExecutable = lib.getExe pkgs.chromium;
  };

  environment.systemPackages = with pkgs; [
    ripgrep
    gh
    go
    python3
    temurin-bin-25
    git
  ];
}
