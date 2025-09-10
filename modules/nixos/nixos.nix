{
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-things.nixosModules.default
    inputs.self.commonModules.default
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
}
