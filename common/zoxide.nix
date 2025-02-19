{
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
}
