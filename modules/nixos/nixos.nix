{
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-things.nixosModules.default
    inputs.self.commonModules.default
  ];

  services.openssh.settings.PasswordAuthentication = false;
}
