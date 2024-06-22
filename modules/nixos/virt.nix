{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hlk.virt;
in {
  options.hlk.virt = {
    default.enable =
      lib.mkEnableOption "default virtualisation tools";
    #TODO: VM and passthrough options
  };
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

    programs.virt-manager.enable = lib.mkIf config.hlk.xserver.default.enable true;

    environment.systemPackages = with pkgs; [
      podman-compose
      qemu
      gvfs
      virtiofsd
    ];
  };
}
