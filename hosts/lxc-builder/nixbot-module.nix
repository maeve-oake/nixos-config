{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nixbot;
  hook = lib.types.submodule {
    options = {
      name = lib.mkOption { type = lib.types.str; };
      repositories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      command = lib.mkOption { type = lib.types.listOf lib.types.str; };
      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };
      warn_only = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };
  extra = (pkgs.formats.json { }).generate "nixbot-finalization.json" {
    evaluation_finished = cfg.evaluationFinished;
    attribute_finished = cfg.attributeFinished;
    build_finished = cfg.buildFinished;
    uploaders = map (u: {
      inherit (u)
        name
        command
        environment
        jobs
        colour
        ;
      paths_via = u.pathsVia;
      plan_command = u.planCommand;
      upload_intermediates = u.uploadIntermediates;
    }) cfg.uploaders;
  };
in
{
  options.services.nixbot = {
    evaluationFinished = lib.mkOption {
      type = lib.types.listOf hook;
      default = [ ];
    };
    attributeFinished = lib.mkOption {
      type = lib.types.listOf hook;
      default = [ ];
    };
    buildFinished = lib.mkOption {
      type = lib.types.listOf hook;
      default = [ ];
    };
    uploaders = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            colour = lib.mkOption {
              type = lib.types.nullOr (lib.types.strMatching "#[0-9a-fA-F]{6}");
              default = null;
            };
            jobs = lib.mkOption {
              type = lib.types.ints.positive;
              default = 1;
            };
            planCommand = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = null;
            };
            uploadIntermediates = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Queue intermediate build outputs for upload as they are built.";
            };
          };
        }
      );
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.nixbot.environment.NIXBOT_EXTRA_CONFIG = extra;
  };
}
