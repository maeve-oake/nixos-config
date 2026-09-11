{
  dateTime.timeZone = "GMT Standard/Daylight Time";

  vendor.display = {
    onTime = "10:00";
    onDuration = "12:00";
    idleTimeout = "00:15";
    # yes, i want the phones ONLY on during weekends.
    inactiveDays = [
      1
      2
      3
      4
      5
    ];
  };

  callManagers = [
    {
      address = "$SIP_DOMAIN";
      sipPort = 5160;
    }
  ];

  sip = {
    dialPlan.templates = [
      {
        match = "*";
        timeout = 5;
        user = "Phone";
      }
    ];

    softKeys = {
      "On Hook" = [
        "Redial"
        "NewCall"
        "DND"
      ];
      "Off Hook" = [
        "Redial"
        "EndCall"
        "DND"
      ];
      "Digits After First" = [
        "<<"
        "EndCall"
      ];
      "Ring Out" = [
        "Undefined"
        "EndCall"
      ];
      "Ring In" = [
        "Answer"
        "DND"
      ];
      "Connected" = [
        "Hold"
        "EndCall"
        "Transfer"
        "Confrn"
        "ConfList"
      ];
      "Connected No Feature" = [
        "Undefined"
        "EndCall"
      ];
      "Connected Transfer" = [
        "Undefined"
        "EndCall"
        "Transfer"
      ];
      "Connected Conference" = [
        "Undefined"
        "EndCall"
        "Confrn"
      ];
      "On Hold" = [
        "Resume"
        "NewCall"
      ];
    };
  };

  phoneServices.services = [
    {
      name = "Missed Calls";
      url = "Application:Cisco/MissedCalls";
    }
    {
      name = "Received Calls";
      url = "Application:Cisco/ReceivedCalls";
    }
    {
      name = "Placed Calls";
      url = "Application:Cisco/PlacedCalls";
    }
    {
      type = "voicemail";
      name = "Voicemail";
      url = "Application:Cisco/Voicemail";
    }
  ];

  urls.authentication = "http://provisioning.centurate.com/cisco.php";
}
