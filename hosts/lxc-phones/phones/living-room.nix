{
  macAddress = "$MAC_LIVING_ROOM";
  wallpaperFile = ../wallpapers/dunder-mifflin.png;

  sip.buttons = [
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
      label = "Maeve";
      speedDialNumber = "350";
    }
  ];
}
