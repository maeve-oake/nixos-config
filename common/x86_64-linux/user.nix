{
  inputs,
  pkgs,
  config,
  ...
}:
{
  age.secrets.maeve-password.file = (inputs.self + /secrets/maeve-password.age);

  users.mutableUsers = false;
  users.users.maeve = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    extraGroups = [
      "wheel" # sudo
      "networkmanager" # network configuration
      "video"
      "input" # three finger drag
      "vboxusers" # vbox
    ];

    shell = pkgs.fish;
    hashedPasswordFile = config.age.secrets.maeve-password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDvkX/XN4U6idAnpWO9JbFpKxJFsvGzfmSCCFKIMmpv maeve@oa.ke"
    ];
  };

  users.groups.users.gid = 100;
}
