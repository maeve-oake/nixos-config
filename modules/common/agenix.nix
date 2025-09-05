{
  inputs,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  config = {
    age.rekey.masterIdentities = [
      {
        identity = "/home/maeve/.ssh/agenix-master";
        pubkey = builtins.readFile (inputs.self.outPath + "/secrets/master-keys/agenix-master.pub");
      }
    ];
  };
}
