{
  ...
}:
{
  networking.networkmanager.ensureProfiles.profiles = {
    Bond = {
      connection = {
        id = "Bond";
        type = "bond";
        interface-name = "bond0";
      };
      bond = {
        mode = "active-backup";
        primary = "enp5s0";
        miimon = "100";
      };
    };
    SFP = {
      connection = {
        id = "SFP";
        type = "ethernet";
        port-type = "bond";
        controller = "bond0";
        interface-name = "enp5s0";
      };
    };
    Ethernet = {
      connection = {
        id = "Ethernet";
        type = "ethernet";
        port-type = "bond";
        controller = "bond0";
        interface-name = "enp13s0";
      };
    };
  };
}
