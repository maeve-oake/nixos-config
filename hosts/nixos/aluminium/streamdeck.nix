{
  pkgs,
  ...
}:
{
  # streamdeck
  services.streamdeck = {
    enable = true;
    config = {
      defaultBrightness = 100;
      defaultPage = "home";
      renderFont = "${pkgs.roboto}/share/fonts/truetype/Roboto-Regular.ttf";
      pages = {
        home.keys = {
          "0" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/book_6.png";
            };
          };
          "1" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/bookmark.png";
            };
            actions = [
              {
                page = {
                  name = "bookmarks";
                };
              }
            ];
          };
          "2" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/badge.png";
            };
            actions = [
              {
                page = {
                  name = "admin";
                };
              }
            ];
          };
          "4" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/apps.png";
            };
            actions = [
              {
                page = {
                  name = "apps";
                };
              }
            ];
          };
        };
        bookmarks.keys = {
          "1" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/arrow_back.png";
            };
            actions = [
              {
                page = {
                  name = "home";
                };
              }
            ];
          };
          "3" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/confirmation_number.png";
              backgroundColor = [
                68
                84
                105
                255
              ];
            };
            actions = [
              {
                page = {
                  name = "home";
                };
              }
            ];
          };
          "4" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/mail.png";
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
        admin.keys = {
          "0" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/person_search.png";
            };
            actions = [
              {
                page = {
                  name = "home";
                };
              }
            ];
          };
          "1" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/alternate_email.png";
            };
            actions = [
              {
                page = {
                  name = "home";
                };
              }
            ];
          };
          "2" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/arrow_back.png";
            };
            actions = [
              {
                page = {
                  name = "home";
                };
              }
            ];
          };
          "3" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/cable.png";
            };
            actions = [
              {
                page = {
                  name = "home";
                };
              }
            ];
          };
          "4" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/settings_account_box.png";
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
        apps.keys = {
          "4" = {
            display.text = {
              image = "/etc/nixos/assets/streamdeck/arrow_back.png";
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
}
