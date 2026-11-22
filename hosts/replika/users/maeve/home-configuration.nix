{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.homeModules.default
  ];

  profiles.workstation.enable = true;

  home.stateVersion = "25.11";
}
