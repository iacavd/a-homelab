{ config, ... }:
{
  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/${config.home.username}" ];
}
