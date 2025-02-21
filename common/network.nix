{
  networking.networkmanager.enable = true;

  # mdns
  services.avahi.enable = false;
  services.resolved.enable = true;

  # ssh
  services.openssh.enable = true;

  # firewall
  networking.firewall.enable = false;

  # tailscale
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
}
