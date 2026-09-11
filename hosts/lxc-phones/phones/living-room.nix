{
  macAddress = "$MAC_LIVING_ROOM";
  wallpaperFile = ../wallpapers/bliss.png;

  sip = {
    phoneLabel = "Sofa";
    buttons = [
      {
        button = 1;
        kind = "line";
        lineIndex = 1;
        port = 5160;
        name = "351";
        authName = "351";
        authPassword = "$SIP_PWD_LIVING_ROOM";
        messagesNumber = "*97";
      }
      {
        button = 2;
        kind = "blf-speed-dial";
        label = "Maeve bedroom";
        speedDialNumber = "350";
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
