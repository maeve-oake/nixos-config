{
  hostName,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.nix-things.darwinModules.default
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.self.commonModules.default
  ];

  # networking
  networking.computerName = hostName;

  # homebrew
  nix-homebrew = {
    user = config.me.username;
    enable = true;

    taps = with inputs; {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };

    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    taps = builtins.attrNames config.nix-homebrew.taps;
  };
}
