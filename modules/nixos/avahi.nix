{ lib, config, pkgs, ... }@inputs: {
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      userServices = true;
      workstation = true;
      addresses = true;
      #not sure what this does
      #domain = true;
    };
  };
}
