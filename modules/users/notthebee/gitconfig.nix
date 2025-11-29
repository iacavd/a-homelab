{
  inputs,
  lib,
  config,
  ...
}:
{
  age.secrets.gitIncludes = {
    file = "${inputs.secrets}/gitIncludes.age";
    path = "$HOME/.config/git/includes";
  };

  programs.git = {
    enable = true;
    userName = "Wolfgang";
    userEmail = "mail@weirdrescue.pw";

    extraConfig = {
      core = {
        sshCommand =
          "ssh -o 'IdentitiesOnly=yes' -i ${config.home.homeDirectory}/.ssh/${config.home.username}";
      };
    };
    includes = [
      {
        path = "~" + (lib.removePrefix "$HOME" config.age.secrets.gitIncludes.path);
        condition = "gitdir:~/Workspace/Projects/";
      }
    ];
  };
}
