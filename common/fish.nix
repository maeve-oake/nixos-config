{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting

      function nsh --wraps nix-shell --description "nix-shell -p <args> --run fish"
        nix-shell -p $argv --run fish
      end
      
      echo "      |\      _,,,---,,_
      ZZZzz /,`.-'`'    -.  ;-;;,_
           |,4-  ) )-,_. ,\ (  `'-'
          '---'''(_/--'  `-'\_)" | lolcat

      zoxide init fish --cmd cd | source
    '';
  };
}
