{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  varsFile = inputs.secrets + "/emily-variables.nix";
  _ = lib.assertMsg (builtins.pathExists varsFile) "Missing emily-variables.nix in secrets input";
  vars = import varsFile;
  wg = config.homelab.networks.external.spencer-wireguard;
  wgBase = lib.strings.removeSuffix ".1" wg.gateway;
  hl = config.homelab;
  baseDomain = config.homelab.baseDomain;
  mainUser = config.homelab.mainUser;
in
{
  services.fail2ban-cloudflare = {
    enable = true;
    apiKeyFile = config.age.secrets.cloudflareFirewallApiKey.path;
    zoneId = vars.cloudflare.zoneId;

  };
  homelab = {
    enable = true;
    baseDomain = baseDomain;
    cloudflare.dnsCredentialsFile = config.age.secrets.cloudflareDnsApiCredentials.path;
    timeZone = "Europe/Berlin";
    mounts = {
      config = "/persist/opt/services";
      slow = "/mnt/mergerfs_slow";
      fast = "/mnt/cache";
      merged = "/mnt/user";
    };
    samba = {
      enable = true;
      passwordFile = config.age.secrets.sambaPassword.path;
      shares = {
        Backups = {
          path = "${hl.mounts.merged}/Backups";
        };
        Documents = {
          path = "${hl.mounts.fast}/Documents";
        };
        Media = {
          path = "${hl.mounts.merged}/Media";
        };
        Music = {
          path = "${hl.mounts.fast}/Media/Music";
        };
        Misc = {
          path = "${hl.mounts.merged}/Misc";
        };
        TimeMachine = {
          path = "${hl.mounts.fast}/TimeMachine";
          "fruit:time machine" = "yes";
        };
        YoutubeArchive = {
          path = "${hl.mounts.merged}/YoutubeArchive";
        };
        YoutubeCurrent = {
          path = "${hl.mounts.fast}/YoutubeCurrent";
        };
      };
    };
    services = {
      enable = true;
      slskd = {
        enable = true;
        environmentFile = config.age.secrets.slskdEnvironmentFile.path;
      };
      backup = {
        enable = true;
        passwordFile = config.age.secrets.resticPassword.path;
        s3.enable = true;
        s3.url = "https://s3.eu-central-003.backblazeb2.com/notthebee-ojfca-backups";
        s3.environmentFile = config.age.secrets.resticBackblazeEnv.path;
        local.enable = true;
      };
      keycloak = {
        enable = true;
        dbPasswordFile = config.age.secrets.keycloakDbPasswordFile.path;
        cloudflared = {
          tunnelId = vars.cloudflare.tunnels.keycloak;
          credentialsFile = config.age.secrets.keycloakCloudflared.path;
        };
      };
      radicale = {
        enable = true;
        passwordFile = config.age.secrets.radicaleHtpasswd.path;
      };
      immich = {
        enable = true;
        mediaDir = "${hl.mounts.fast}/Media/Photos";
      };
      invoiceplane = {
        enable = true;
      };
      homepage = {
        enable = true;
        misc = [
          {
            PiKVM =
              let
                ip = config.homelab.networks.local.lan.reservations.pikvm.Address;
              in
              {
                href = "https://${ip}";
                siteMonitor = "https://${ip}";
                description = "Open-source KVM solution";
                icon = "pikvm.png";
              };
          }
          {
            FritzBox = {
              href = "http://192.168.178.1";
              siteMonitor = "http://192.168.178.1";
              description = "Cable Modem WebUI";
              icon = "avm-fritzbox.png";
            };
          }
          {
            "Immich (Parents)" = {
              href = "https://photos.aria.${baseDomain}";
              description = "Self-hosted photo and video management solution";
              icon = "immich.svg";
              siteMonitor = "";
            };
          }
        ];
      };
      jellyfin.enable = true;
      paperless = {
        enable = true;
        passwordFile = config.age.secrets.paperlessPassword.path;
      };
      sabnzbd.enable = true;
      sonarr.enable = true;
      radarr.enable = true;
      bazarr.enable = true;
      prowlarr.enable = true;
      jellyseerr = {
        enable = true;
        package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.jellyseerr;
      };
      nextcloud = {
        enable = true;
        admin = {
          username = mainUser;
          passwordFile = config.sops.secrets.nextcloud-admin-pass.path;
        };
        cloudflared = {
          tunnelId = vars.cloudflare.tunnels.nextcloud;
          credentialsFile = config.age.secrets.nextcloudCloudflared.path;
        };
      };
      vaultwarden = {
        enable = true;
        cloudflared = {
          tunnelId = vars.cloudflare.tunnels.vaultwarden;
          credentialsFile = config.age.secrets.vaultwardenCloudflared.path;
        };
      };
      microbin = {
        enable = true;
        cloudflared = {
          tunnelId = vars.cloudflare.tunnels.microbin;
          credentialsFile = config.age.secrets.microbinCloudflared.path;
        };
      };
      miniflux = {
        enable = true;
        cloudflared = {
          tunnelId = vars.cloudflare.tunnels.miniflux;
          credentialsFile = config.age.secrets.minifluxCloudflared.path;
        };
        adminCredentialsFile = config.sops.secrets.miniflux-admin.path;
      };
      navidrome = {
        enable = true;
        environmentFile = config.age.secrets.navidromeEnv.path;
        cloudflared = {
          tunnelId = vars.cloudflare.tunnels.navidrome;
          credentialsFile = config.age.secrets.navidromeCloudflared.path;
        };
      };
      audiobookshelf.enable = true;
      deluge.enable = true;
      wireguard-netns = {
        enable = true;
        configFile = config.age.secrets.wireguardCredentials.path;
        privateIP = "${wgBase}.2";
        dnsIP = wg.gateway;
      };
    };
  };
}
