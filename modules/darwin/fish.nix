{
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    zoxide init fish --no-cmd --cmd cd | source
  '';
}
