{
  macAddress = "$MAC_MAEVE";
  wallpaperFile = ../wallpapers/dunder-mifflin.png;

  sip = {
    phoneLabel = "Maeve";
    buttons = [
      {
        button = 1;
        kind = "line";
        lineIndex = 1;
        port = 5160;
        name = "350";
        authName = "350";
        authPassword = "$SIP_PWD_MAEVE";
        messagesNumber = "*97";
      }
      {
        button = 2;
        kind = "blf-speed-dial";
        label = "Living room";
        speedDialNumber = "351";
      }
      {
        button = 3;
        kind = "blf-speed-dial";
        label = "Anya Raccoon";
        speedDialNumber = "300";
      }
      {
        button = 4;
        kind = "blf-speed-dial";
        label = "Anya macOS";
        speedDialNumber = "100";
      }
      {
        button = 6;
        kind = "blf-speed-dial";
        label = "Maeve mobile";
        speedDialNumber = "$SPEEDDIAL_MAEVE";
      }
      {
        button = 7;
        kind = "blf-speed-dial";
        label = "Lily mobile";
        speedDialNumber = "$SPEEDDIAL_LILY";
      }
      {
        button = 8;
        kind = "blf-speed-dial";
        label = "Zoë mobile";
        speedDialNumber = "$SPEEDDIAL_ZOE";
      }
    ];
  };
}
