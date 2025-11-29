{
  config,
  pkgs,
  lib,
  ...
}:
let
  mainUser = config.homelab.mainUser;
  mediaGroup = config.homelab.mediaGroup;
in {
  nix.settings.trusted-users = [
    "root"
    mainUser
    "@wheel"
  ];

  users = {
    users = {
      ${mainUser} = {
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "users"
          "video"
          "podman"
          "input"
          mediaGroup
        ];
        group = mainUser;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGUGMUo1dRl9xoDlMxQGb8dNSY+6xiEpbZWAu6FAbWw moe@notthebe.ee"
        ];
      };
    };
    groups =
      {
        ${mainUser} = {
          gid = 1000;
        };
      }
      // lib.optionalAttrs (mediaGroup != mainUser) { ${mediaGroup} = { }; };
  };
  programs.zsh.enable = true;

}
