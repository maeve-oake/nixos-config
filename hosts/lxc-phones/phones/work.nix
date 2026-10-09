{
  ip = "10.0.4.83";
  macAddress = "$MAC_WORK";
  deviceModel = "7965G";
  wallpaperFile = ../wallpapers/bliss-7965.png;

  sip = {
    phoneLabel = "Maeve Office";
    buttons = [
      {
        button = 1;
        kind = "line";
        lineIndex = 1;
        port = 5160;
        name = "360";
        authName = "360";
        authPassword = "$SIP_PWD_WORK";
        messagesNumber = "*97";
      }
      {
        button = 2;
        kind = "blf-speed-dial";
        label = "Home";
        speedDialNumber = "350";
      }
    ];
  };
}
