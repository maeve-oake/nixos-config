{
  programs.fish.enable = true;
  programs.zoxide = {
    enable = true;
    flags = [
      "--cmd cd"
    ];
  };
  programs.fzf.fuzzyCompletion = true;
}
