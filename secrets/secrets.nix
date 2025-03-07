let
  maeve = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDvkX/XN4U6idAnpWO9JbFpKxJFsvGzfmSCCFKIMmpv";
  replika = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOM0F0SG96eXo7K5In/cFi3/R8JyU7uGrmir8s/qDf87";
  aluminium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjsH0Zu/aVH+uDjzALotADjozJp0yfrf4OAIVJFXud3";
  hosts = [ replika aluminium ];
in
{
  "maeve-password.age".publicKeys = [ maeve ] ++ hosts;
  "mynah-vault.age".publicKeys = [ maeve replika ];
  "mynah-smb.age".publicKeys = [ maeve replika ];
}
