{
  config,
  lib,
  pkgs,
  modulesPath,
  volatile,
  pkgsARM,
  mobile,
  secrets,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # TODO: modify to fit the new phon
    # volatile.north
    # TODO: mobile-nixos quirk modules
  ];

  nix.settings.cores = 4;

  zramSwap.enable = true;

  services.kmscon.enable = lib.mkForce true;

  hardware.graphics.enable32Bit = lib.mkForce false;

  #TODO: copy other things from enchilada hardware definitions
  #TODO: load correct modules in initrd (take them from pmos device definition)
}
