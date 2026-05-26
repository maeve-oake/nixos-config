{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./user.nix
  ];

  config = lib.mkIf config.profiles.server.enable {
    lxc.pve.host = lib.mkDefault ("mynah." + config.me.lanDomain);

    programs.nix-index.enable = false;

    environment.systemPackages = with pkgs; [
      ghostty.terminfo
    ];

    # mynah host driver
    lxc.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "580.159.04";
      sha256_64bit = "sha256-weZnYbCI0Xs632y2l53przi+JoTRArABoXbc+vq9yh4=";
      openSha256 = "sha256-zsNmjZW0cyZWPp3vDT3mNeqAo0hS0M7e9Tbvwvij+F4=";
      useSettings = false;
      usePersistenced = false;
    };
  };
}
