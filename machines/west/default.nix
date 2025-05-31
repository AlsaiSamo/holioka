{
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
} @ inputs: {
  hlk = {
    common.enable = true;
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
    sshd = {
      default.enable = true;
      rootKeysFrom = secrets.west.authorizedKeyFiles;
    };
    #TODO: remove
    graphical.windowSystem = "xorg";
    fcitx.enable = true;

    mainUserRewrite = {
      enable = true;
      userName = "imikoy";
      userConfig = {
        common.enable = true;
        work.enable = true;
        graphical.windowSystem = "xorg";
        emacs.default.enable = true;
        games = {
          osu.state.enable = true;
          xonotic.enable = true;
          xonotic.state.enable = true;
        };
        cli = {
          core.enable = true;
          extra.enable = true;
          shell = "zsh";
          starship.enable = true;
        };
        network = {
          manager = "iwd";
          hostName = "west";
        };
        firefox.default.enable = true;
        gpg.default.enable = true;
        nvim.default.enable = true;
        krita.enable = true;
        fcitx.enable = true;
        nheko.enable = true;
        keepass.enable = true;
      };
      extraHmConfig = {};
    };
  };

  # protracted imikoy's war against adhd
  networking.hosts = {
    "127.0.0.1" = ["youtube.com" "hexbear.net" "lemmy.ml" "reddit.com"];
  };

  nix.extraOptions = ''
    extra-platforms = aarch64-linux
  '';
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  #TODO: move this into work usermodule
  services.openvpn.servers.work = {
    updateResolvConf = true;
    config = secrets.work.vpn_conf;
  };
  environment.systemPackages = with pkgs; [
    openvpn
  ];

  #TODO: do this for all machines
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [libGL];
  };

  #TODO: squash input-leap into virtualisation module
  specialisation."vm-with-nvidia-gpu" = {
    inheritParentConfig = true;
    configuration = {
      system.nixos.tags = ["nvidia-vfio"];
      hlk = {
        virt = {
          VMConfigsToLink = ["fedora40"];
        };
        input-leap.enable = true;
      };

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
