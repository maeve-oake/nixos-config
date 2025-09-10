{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.profiles.workstation.enable {
    programs.fish.interactiveShellInit = ''
      zoxide init fish --no-cmd --cmd cd | source
    '';
  };
}
