{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.clolcat ];
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    flags = [
      "--no-cmd"
      "--cmd cd"
    ];
  };
  programs.fzf.fuzzyCompletion = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
        echo "      |\      _,,,---,,_
      ZZZzz /,`.-'`'    -.  ;-;;,_
           |,4-  ) )-,_. ,\ (  `'-'
          '---'''(_/--'  `-'\_)" | clolcat
      end

      function nsh --wraps nix-shell --description "nix-shell -p <args> --run fish"
        nix-shell -p $argv --run fish
      end

      function ncd --description "cd into nix store path of a package"
        set package_name $argv[1]
        if test -z "$package_name"
          echo "Usage: ncd <package-name>"
          return 1
        end
        set store_path (NIXPKGS_ALLOW_UNFREE=1 nix path-info nixpkgs#$package_name --impure | string trim)
        if test -z "$store_path"
          echo "Could not find nix store path for package: $package_name"
          return 1
        end
        cd $store_path
      end

      export NIXPKGS_ALLOW_UNFREE=1
    '';
  };
}
