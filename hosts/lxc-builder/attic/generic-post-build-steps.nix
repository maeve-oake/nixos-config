{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.buildbot-nix.master;
  definitions = (pkgs.formats.json { }).generate "generic-post-build-steps.json" (
    map (step: {
      inherit (step) name type options;
      warn_only = step.warnOnly;
    }) cfg.genericPostBuildSteps
  );
in
{
  # Transform the final package so this composes with unrelated overrides,
  # including infra's patches, without owning or duplicating their definition.
  options.services.buildbot-nix.packages.buildbot-nix = lib.mkOption {
    apply =
      package:
      package.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./generic-post-build-steps.patch ];
      });
  };

  options.services.buildbot-nix.master.genericPostBuildSteps = lib.mkOption {
    default = [ ];
    description = "Post-build steps instantiated by registered Python factories, after postBuildSteps.";
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Buildbot step name.";
          };
          type = lib.mkOption {
            type = lib.types.str;
            description = "Factory name; shell or a buildbot_nix.post_build_steps entry point.";
          };
          options = lib.mkOption {
            type = lib.types.attrsOf (pkgs.formats.json { }).type;
            default = { };
            description = "Options passed to the step factory.";
          };
          warnOnly = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Treat failure as a warning.";
          };
        };
      }
    );
  };

  config = lib.mkIf (cfg.enable && cfg.genericPostBuildSteps != [ ]) {
    services.buildbot-master.extraConfig = ''
      import json
      from pathlib import Path
      from buildbot_nix import NixConfigurator
      from buildbot_nix.models import PostBuildStep
      generic_steps = json.loads(Path('${definitions}').read_text())
      nix_configurators = [item for item in c['configurators'] if isinstance(item, NixConfigurator)]
      if len(nix_configurators) != 1:
          raise ValueError('genericPostBuildSteps requires exactly one NixConfigurator')
      nix_configurators[0].config.post_build_steps.extend(
          PostBuildStep.model_validate(step) for step in generic_steps
      )
    '';
  };
}
