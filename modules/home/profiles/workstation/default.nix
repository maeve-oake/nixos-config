{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.profiles.workstation.enable {
    programs.ai.enable = true;
  };
}
