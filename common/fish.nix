{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.lolcat ];
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
        echo "      |\      _,,,---,,_
      ZZZzz /,`.-'`'    -.  ;-;;,_
           |,4-  ) )-,_. ,\ (  `'-'
          '---'''(_/--'  `-'\_)" | lolcat
      end

      function nsh --wraps nix-shell --description "nix-shell -p <args> --run fish"
        nix-shell -p $argv --run fish
      end
      
      zoxide init fish --cmd cd | source
    '';
  };
}
