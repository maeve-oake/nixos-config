{
  macAddress = "$MAC_MAEVE";
  wallpaperFile = ../wallpapers/dunder-mifflin.png;

  sip.buttons = [
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
  ];
}
