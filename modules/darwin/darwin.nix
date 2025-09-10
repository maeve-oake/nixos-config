{
  hostName,
  inputs,
  ...
}:
{
  imports = [
    inputs.self.commonModules.default
  ];

  # networking
  networking.computerName = hostName;
}
