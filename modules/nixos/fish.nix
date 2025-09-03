{
  programs.zoxide = {
    enable = true;
    flags = [
      "--cmd cd"
    ];
  };
  programs.fzf.fuzzyCompletion = true;
}
