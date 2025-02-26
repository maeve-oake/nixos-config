{ pkgs, ... }:
{
    users.knownUsers = [ "maeve" ];
    users.users.maeve = {
        shell = pkgs.fish;
        uid = 501;
    };
}