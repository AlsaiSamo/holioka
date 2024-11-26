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
    VMConfigsToLink = lib.mkOption {
      example = ["fedora40"];
      default = [];
      description = "Virtual machines which configs should be linked";
      type = lib.types.listOf lib.types.str;
    };
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
    networking.firewall.interfaces."virbr*".allowedUDPPorts = [53 67];
    networking.firewall.interfaces."virbr*".allowedTCPPorts = [24800];

    programs.virt-manager.enable = lib.mkIf (config.hlk.graphical.windowSystem != "none") true;

    environment.persistence."/state".files =
      lib.mkIf (cfg.VMConfigsToLink != [])
      (lib.lists.flatten (map (x: [
          ("/var/lib/libvirt/qemu/" + x + ".xml")
          ("/var/lib/libvirt/qemu/nvram/" + x + "_VARS.fd")
        ])
        cfg.VMConfigsToLink));

    environment.persistence."/state" = {
      directories = [
        "/var/lib/libvirt/storage"
        "/var/lib/libvirt/qemu/networks"
      ];
    };

    environment.systemPackages = with pkgs; [
      podman-compose
      qemu
      gvfs
      virtiofsd
    ];
  };
}
