{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.profiles.workstation.personal.enable {
    programs.direnv.enable = true;

    programs._1password.enable = true;
    programs._1password-gui.enable = true;
  };
}
