{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.profiles.workstation.enable {
    programs.fish.interactiveShellInit = ''
      zoxide init fish --cmd cd | source
    '';
  };
}
