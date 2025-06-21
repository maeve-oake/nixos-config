{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # apps
    (microsoft-edge.override {
      commandLineArgs = [
        "--enable-features=TouchpadOverscrollHistoryNavigation,Vulkan,VaapiVideoDecoder,VaapiIgnoreDriverChecks,DefaultANGLEVulkan,VulkanFromANGLE"
      ];
    })
    discord
  ];
}
