{ config, lib, pkgs, ... }:

{
  # Path to the age private key file on this host.
  # The user will create this file at deploy-time.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # This host's secrets live in secrets/emily.yaml at the repo root.
  # Adjust the relative path if necessary based on actual location.
  sops.defaultSopsFile = ../../../../secrets/emily.yaml;

  # Declare individual secrets (keys in secrets/emily.yaml).
  sops.secrets = {
    nextcloud-admin-pass = { };
    vaultwarden-env      = { };
    miniflux-admin       = { };
    microbin-password    = { };
  };

  # Wire secrets into services.

  # Nextcloud admin password file
  services.nextcloud.config.adminpassFile =
    config.sops.secrets.nextcloud-admin-pass.path;

  # Vaultwarden environment file
  services.vaultwarden.environmentFile =
    config.sops.secrets.vaultwarden-env.path;

  # Miniflux admin credentials file
  services.miniflux.adminCredentialsFile =
    config.sops.secrets.miniflux-admin.path;

  # Microbin password file
  services.microbin.passwordFile =
    config.sops.secrets.microbin-password.path;
}
