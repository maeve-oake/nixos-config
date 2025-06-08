{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.lnxlink;
  yaml = pkgs.formats.yaml { };

  allAddons = cfg.package.meta.addons.allNames;

  envFileType =
    with lib;
    mkOptionType {
      name = "envFile";
      description = "Path to an env file with secrets - outside of nix store";
      descriptionClass = "noun";
      check = x: !(isStorePath x);
      merge = lib.mergeEqualOption;
    };

  settings = {
    update_interval = 5;
    update_on_change = false;
    hass_url = null;
    hass_api = null;
    modules = enabledAddonsNames;
    custom_modules = null;
    exclude = [ ];
    mqtt = {
      prefix = "lnxlink";
      clientId = cfg.clientId;
      server = null;
      port = 1883;
      auth = {
        user = null;
        pass = null;
        tls = false;
        keyfile = null;
        certfile = null;
        ca_certs = null;
      };
      discovery = {
        enabled = true;
      };
      lwt = {
        enabled = true;
        qos = 1;
        retain = false;
      };
    };
    settings = {
      systemd = null;
      gpio = {
        inputs = null;
        outputs = null;
      };
      hotkeys = null;
      disk_usage = {
        include_disks = [ ];
        exclude_disks = [ ];
      };
      statistics = "https://analyzer.bkbilly.workers.dev"; # XXX ?
      bash = {
        allow_any_command = false;
        expose = null;
      };
      mounts = {
        autocheck = false;
        directories = [ ];
      };
      ir_remote = {
        receiver = null;
        transmitter = null;
        buttons = [ ];
      };
      restful = {
        port = 8112;
      };
      battery = {
        include_batteries = [ ];
        exclude_batteries = [ ];
      };
    };
  };

  configFile = yaml.generate "lnxlink-config.yaml" settings;

  addonOptions =
    nm:
    let
      meta = cfg.package.meta.addons.getMeta nm;
      variants =
        (
          {
            variants ? { },
            ...
          }:
          builtins.attrNames variants
        )
          meta;
      maybeVariantOption =
        if (builtins.length variants > 0) then
          {
            variant =
              with lib;
              mkOption {
                type = types.enum variants;
                default = null;
                description = ''
                  Which variant of this addon to enable (e.g. 'amd' or 'nvidia' for 'gpu' addon).
                '';
              };
          }
        else
          { };
    in
    {
      name = nm;
      value = {
        enable = lib.mkEnableOption "Enable addon ${nm}";
      } // maybeVariantOption;
    };

  enabledAddonsNames = builtins.filter (x: cfg.addons."${x}".enable) allAddons;

  # XXX variants
  finalPackage = cfg.package.override { addons = enabledAddonsNames; };
in
{
  options.services.lnxlink = {
    enable = lib.mkEnableOption "LNXlink";

    clientId = lib.mkOption {
      type = lib.types.str;
      default = "lnxlink";
      description = "MQTT client ID for LNXlink";
    };

    addons = builtins.listToAttrs (builtins.map addonOptions allAddons);

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "DEBUG"
        "INFO"
        "WARNING"
        "ERROR"
        "CRITICAL"
      ];
      default = "INFO";
    };

    envFile = lib.mkOption { type = envFileType; };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.lnxlink;
    };
  };

  config = lib.mkIf cfg.enable {
    # XXX assertions = [ <variant-is-chosen-for-enabled-modules-with-variants>  ];

    systemd.services.lnxlink = {
      description = "LNXlink";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        mkdir -p /var/lib/lnxlink
        cd /var/lib/lnxlink
        exec ${lib.getExe finalPackage} --ignore-systemd --config "${configFile}" --logging ${cfg.logLevel}
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 5;
        EnvironmentFile = cfg.envFile;
      };
    };
  };
}
