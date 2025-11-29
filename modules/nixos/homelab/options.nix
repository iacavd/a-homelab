{ lib, ... }:

let
  inherit (lib) mkOption types;
in {
  # Global homelab parameters for user, domain, and group ownership.
  options.homelab = {
    mainUser = mkOption {
      type = types.str;
      default = "abdul";    # primary homelab user
      description = "Primary NixOS user for the homelab.";
    };

    baseDomain = mkOption {
      type = types.str;
      default = "home.lab"; # internal base domain; user can override later
      description = "Base DNS domain used for services (e.g. jellyfin.<baseDomain>).";
    };

    mediaGroup = mkOption {
      type = types.str;
      default = "media";
      description = "Group owning media libraries and media services.";
    };
  };
}
