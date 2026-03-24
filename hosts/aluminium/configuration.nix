{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.default
    ./hardware-configuration.nix
  ];

  profiles.workstation = {
    enable = true;
    laptop.enable = true;
    samba.enable = true;
    wifi.enable = true;
    work-vpn.enable = true;
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
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.loader.systemd-boot.configurationLimit = 1;

  # fingerprint & login
  security.polkit.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    # apps
    (teams-for-linux.overrideAttrs (old: {
      installPhase =
        builtins.replaceStrings
          [
            ''--add-flags "$out/share/teams-for-linux/app.asar" \''
          ]
          [
            ''
              --add-flags "$out/share/teams-for-linux/app.asar" \
              --add-flags "--disable-pinch" \''
          ]
          old.installPhase;
    }))
    xclip
  ];

  age.secrets = {
    streamdeck-vars = {
      owner = "maeve";
      group = "users";
    };
  };

  services.streamdeck.configPath = "/home/maeve/Documents/streamdeck/config.yaml";

  # streamdeck
  services.streamdeck = {
    user = config.me.username;
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
                text = "0";
                border = 20;
              };
            };
            "1" = {
              display.text = {
                text = "1";
                image = "/home/maeve/Documents/streamdeck/icons/BACK.png";
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
                text = "2";
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
              display.text = {
                text = "3";
              };
              actions = [
                {
                  page = {
                    name = "weblinks";
                  };
                }
              ];
            };
            "4" = {
              display.text = {
                text = "4";
              };
              actions = [
                {
                  page = {
                    name = "weblinks";
                  };
                }
              ];
            };
            "5" = {
              display.text = {
                text = "5";
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
        scripts = {
          keys = {

          };
        };
      };
    };
  };

  # Do not remove
  system.stateVersion = "24.05";
}
