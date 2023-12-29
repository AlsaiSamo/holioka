{
  config,
  lib,
  pkgs,
  ...
} @ inputs:
#TODO: store personal key in repo
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      #TODO: here I can define the identity to use for github
    };
  };
}
