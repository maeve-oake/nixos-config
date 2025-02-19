{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      
      echo "      |\      _,,,---,,_
      ZZZzz /,`.-'`'    -.  ;-;;,_
           |,4-  ) )-,_. ,\ (  `'-'
          '---'''(_/--'  `-'\_)" | lolcat

      zoxide init fish --cmd cd | source
    '';
  };
}
