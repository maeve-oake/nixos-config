{
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    flags = [
      "--no-cmd"
      "--cmd cd"
    ];
  };
  programs.fzf.fuzzyCompletion = true;
}
