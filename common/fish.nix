{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting "GAY SEX"
      zoxide init fish --cmd cd | source
    '';
  };
}
