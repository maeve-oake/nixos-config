{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    ./hardware-configuration.nix
  ];

  profiles.workstation = {
    enable = true;
    wifi.enable = true;
  };

  # DE
  profiles.workstation.gnome = {
    enable = true;
    dockItems.middle = [
      "teams-for-linux.desktop"
      "org.gnome.Calendar.desktop"
    ];
  };

  # boot
  boot.secureboot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_6_17;
  boot.loader.systemd-boot.configurationLimit = 1;

  # power & sleep
  systemd.sleep.extraConfig = ''
    		HibernateDelaySec=30m
    	'';
  services.logind.lidSwitch = "suspend-then-hibernate";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # fix electron blur
  };

  # fingerprint & login
  security.polkit.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    # apps
    teams-for-linux
  ];

  # streamdeck
  services.streamdeck = {
    enable = true;
    config = {
      defaultBrightness = 100;
      defaultPage = "home";
      renderFont = "${pkgs.roboto}/share/fonts/truetype/Roboto-Regular.ttf";
      pages = {
        home = {
          keys = {
            "0" = {
              display.text = {
                text = "zero";
                border = 20;
              };
            };
            "1" = {
              display.text = {
                text = "weblinks";
                image = "/home/maeve/Documents/streamdeck/icons/maeve_cat.jpg";
              };
              actions = [
                {
                  page = {
                    name = "weblinks";
                  };
                }
              ];
            };
            "2" = {
              display.text = {
                text = "edge";
              };
              actions = [
                {
                  page = {
                    name = "weblinks";
                  };
                }
              ];
            };
            "3" = {
              display.image = {
                url = "https://les.bi/images/maeve.png";
              };
              actions = [
                {
                  page = {
                    name = "weblinks";
                  };
                }
              ];
            };
          };
        };
        weblinks = {
          keys = {
            "1" = {
              display.text = {
                text = "back";
              };
              actions = [
                {
                  page = {
                    name = "home";
                  };
                }
              ];
            };
          };
        };
      };
    };
  };

  # Do not remove
  system.stateVersion = "24.05";
}
