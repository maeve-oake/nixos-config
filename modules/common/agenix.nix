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
        # TODO: remove this!
        identity = "/home/maeve/.ssh/agenix-master";
        pubkey = builtins.readFile (inputs.self.outPath + "/secrets/master-keys/agenix-master.pub");
      }
      {
        identity = "/home/maeve/.ssh/agenix-master-pq";
        pubkey = builtins.readFile (inputs.self.outPath + "/secrets/master-keys/agenix-master-pq.pub");
      }
    ];
  };
}
