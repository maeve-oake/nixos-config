let
  maeve = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDvkX/XN4U6idAnpWO9JbFpKxJFsvGzfmSCCFKIMmpv";
  replika = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOM0F0SG96eXo7K5In/cFi3/R8JyU7uGrmir8s/qDf87";
  aluminium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjsH0Zu/aVH+uDjzALotADjozJp0yfrf4OAIVJFXud3";
  elster = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzeE24EUgkih3TLH7hn5ZsHcACIsk6VAVl3ve2SaSgF";
  stainless = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+t14PSPA87rn3D/V71YhTkQSpy6xhXrQ7JCXI/AiJO";
  hosts = [
    replika
    aluminium
    elster
  ];
  all = [ maeve ] ++ hosts;
in
{
  "maeve-password.age".publicKeys = all;
  "mynah-vault.age".publicKeys = [
    maeve
    replika
  ];
  "mynah-smb.age".publicKeys = [
    maeve
    replika
  ];
  "attic-netrc.age".publicKeys = all ++ [ stainless ];

  # wifi
  "wifi-home.age".publicKeys = all;
  "wifi-hotspot.age".publicKeys = all;
  "wifi-work.age".publicKeys = all;

  # services
  "lnxlink-env.age".publicKeys = all;
}
