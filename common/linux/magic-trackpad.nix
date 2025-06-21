{
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Apple Magic Trackpad USB-C (Bluetooth)]
    MatchBus=bluetooth
    MatchVendor=0x004C
    MatchProduct=0x0324
    AttrTouchSizeRange=20:10
    AttrPressureRange=3:0
    AttrPalmSizeThreshold=900
    AttrThumbSizeThreshold=700

    [Apple Magic Trackpad USB-C (USB)]
    MatchBus=usb
    MatchVendor=0x05AC
    MatchProduct=0x0324
    AttrTouchSizeRange=20:10
    AttrPressureRange=3:0
    AttrPalmSizeThreshold=900
    AttrThumbSizeThreshold=700
  '';
}
