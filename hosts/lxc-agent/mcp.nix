{
  config,
  pkgs,
  ...
}:
{
  age.secrets = {
    "lxc-agent/mcpproxy/encryption-key" = { };
    "lxc-agent/mcpproxy/oidc-client-id" = { };
    "lxc-agent/mcpproxy/oidc-client-secret" = { };
  };

  services.mcpproxy = {
    enable = true;
    user = "agent";
    group = "agent";

    path = with pkgs; [
      bash
      nodejs-slim
      nodejs-slim.npm
      uv
      python3
    ];

    settings = {
      listen = "0.0.0.0:3333";
      encryptionKeyFile = config.age.secrets."lxc-agent/mcpproxy/encryption-key".path;

      oidc = {
        issuer = "https://auth.oa.ke";
        clientIdFile = config.age.secrets."lxc-agent/mcpproxy/oidc-client-id".path;
        clientSecretFile = config.age.secrets."lxc-agent/mcpproxy/oidc-client-secret".path;
      };
    };
  };
}
