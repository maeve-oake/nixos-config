{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.profiles.workstation.enable {
    programs.zoxide = {
      enable = true;
      flags = [
        "--cmd cd"
      ];
    };
    programs.fzf.fuzzyCompletion = true;
  };
}
