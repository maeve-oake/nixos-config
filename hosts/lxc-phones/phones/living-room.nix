{
  macAddress = "$MAC_LIVING_ROOM";
  wallpaperFile = ../wallpapers/bliss.png;

  urls.services = "http://replika.lan.ci:5220/app.xml";

  addOnModules = [
    {
      index = 1;
      deviceType = "7916";
    }
  ];

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
      {
        button = 9;
        kind = "blf-speed-dial";
        label = "Floor lamp";
        speedDialNumber = "***1337*01";
        featureOptionMask = "presence-only";
      }
      {
        button = 10;
        kind = "service-url";
        label = "Floor lamp menu";
        serviceURI = "http://replika.lan.ci:5220/ha/touch.xml";
      }
      {
        button = 11;
        kind = "blf-speed-dial";
        label = "Air conditioner";
        speedDialNumber = "***1337*02";
        featureOptionMask = "presence-only";
      }
      {
        button = 12;
        kind = "service-url";
        label = "Air conditioner menu";
        serviceURI = "http://replika.lan.ci:5220/ha/aircon.xml";
      }
      {
        button = 32;
        kind = "blf-speed-dial";
        label = "Saul Badman";
        speedDialNumber = "67";
      }
    ];
  };
}
