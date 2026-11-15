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
        ;
      paths_via = u.pathsVia;
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
          options.jobs = lib.mkOption {
            type = lib.types.ints.positive;
            default = 1;
          };
        }
      );
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.nixbot.environment.NIXBOT_EXTRA_CONFIG = extra;
  };
}
