{
  config,
  lib,
  pkgs,
  ...
} @ inputs:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      #TODO: here I can define the identity to use for github
    };
  };
}
