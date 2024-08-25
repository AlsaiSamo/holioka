{
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
} @ inputs: {
  imports = [
    ./hardware.nix
    ../../modules/nixos/common.nix
  ];

  hlk = {
    defaultFilesystems = true;
    stateRemoval.enable = true;
    backup.enable = true;
    flatpak.default.enable = true;
    audio = {
      default.enable = true;
      desktop.enable = true;
      lowLatency.enable = true;
    };
    virt.default.enable = true;
    network = {
      default.enable = true;
      desktop.enable = true;
      hostName = "west";
    };
    sshd = {
      default.enable = true;
      root_keys_from = secrets.west.authorizedKeyFiles;
    };
    xserver.default.enable = true;
    mainUser = {
      default.enable = true;
    };
    jp.enable = true;
  };

  services.openvpn.servers.work = {
    updateResolvConf = true;
    config = secrets.work.vpn_conf;
  };
  environment.systemPackages = with pkgs; [
    openvpn
  ];

  specialisation."vm-with-nvidia-gpu" = {
    inheritParentConfig = true;
    configuration = {
      system.nixos.tags = ["nvidia-vfio"];
      hlk = {
        virt = {
          VMConfigsToLink = [ "fedora40" ];
        };
        input-leap.enable = true;
      };

      #TODO: do stuff here:
      #1. configure input-leap on both machines
      #2. yay we can develop mesa
      hardware.nvidia = {
        prime.sync.enable = lib.mkForce false;
        prime.offload.enable = lib.mkForce false;
      };
      boot.initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];
      boot.kernelParams = [
        "vfio-pci.ids=10de:1f99,10de:10fa"
      ];
      boot.blacklistedKernelModules = ["nouveau" "nvidia" "nvidia_drm" "nvidia_modeset"];
      boot.kernelModules = ["kvm-amd" "amdgpu" "acpi_call"];
      services.xserver.videoDrivers = ["amdgpu"];

      hardware.graphics.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;
    };
  };

  system.stateVersion = "23.11";
}
