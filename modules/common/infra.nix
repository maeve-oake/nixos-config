{ config, ... }:
{
  age.secrets."infra-token" = { };
  infra = {
    flakeRepo = "maeve-oake/nixos-config";
    hubTokenFile = config.age.secrets."infra-token".path;
  };
}
