{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hlk.virt;
in {
  options.hlk.virt.default.enable =
    lib.mkEnableOption "default virtualisation tools";
  config = lib.mkIf cfg.default.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    virtualisation.libvirtd = {
      enable = true;
    };
    #TODO: this is graphocal option
    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [podman-compose qemu gvfs virtiofsd];
  };
}
