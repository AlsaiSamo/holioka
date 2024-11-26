{
  config,
  lib,
  pkgs,
  mobile-nixos,
  #pkgsFinal,
  kernel,
  ...
}:
#Installer image for enchilada
let
  enchilada_firmware = pkgs.stdenvNoCC.mkDerivation {
    name = "firmware-oneplus-sdm845";
    src = pkgs.fetchFromGitLab {
      owner = "sdm845-mainline";
      repo = "firmware-oneplus-sdm845";
      rev = "dc9c77f220d104d7224c03fcbfc419a03a58765e";
      hash = "sha256-jrbWIS4T9HgBPYOV2MqPiRQCxGMDEfQidKw9Jn5pgBI=";
    };
    installPhase = ''
      cp -a . "$out"
      cd "$out/lib/firmware/postmarketos"
      find . -type f,l | xargs -i bash -c 'mkdir -p "$(dirname "../$1")" && mv "$1" "../$1"' -- {}
      cd "$out/usr"
      find . -type f,l | xargs -i bash -c 'mkdir -p "$(dirname "../$1")" && mv "$1" "../$1"' -- {}
      cd ..
      find "$out"/{usr,lib/firmware/postmarketos} | tac | xargs rmdir
    '';
    dontStrip = true;
    meta.license = lib.licenses.unfree;
  };
in {
  imports =
    [
      #(import "${mobile-nixos}/examples/installer/configuration.nix")
      # (import "${mobile-nixos}/lib/configuration.nix" {device = "oneplus-enchilada";})
      #TODO figure out what exactly causes crashdump
      (import "${mobile-nixos}/devices/families/sdm845-mainline/default.nix")
      # ];
    ]
    ++ (import "${mobile-nixos}/modules/module-list.nix");
  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor kernel);

  mobile.boot.stage-1.kernel = {
    package = lib.mkForce kernel;
    useNixOSKernel = lib.mkForce true;
    useStrictKernelConfig = lib.mkDefault true;
  };
  mobile.system.type = lib.mkForce "uefi";
  mobile.generatedFilesystems = {
    boot.size = lib.mkForce (pkgs.image-builder.helpers.size.MiB 240);
    boot.blockSize = 4096;
    boot.sectorSize = 4096;
  };

  #taken from lib/configuration.nix-imported enchilada config
  mobile.system.android.device_name = "OnePlus6";
  mobile.hardware = {
    ram = 1024 * 8;
    screen = {
      width = 1080;
      height = 2280;
    };
  };
  mobile.device.name = "oneplus-enchilada";
  mobile.device.identity = {
    name = "OnePlus 6";
    manufacturer = "OnePlus";
  };
  mobile.device.supportLevel = "supported";

  #TODO: initrd
  #TODO: efistub fails to load dtb
  boot.consoleLogLevel = 7;
  hardware.deviceTree.enable = true;
  hardware.deviceTree.name = "qcom/sdm845-oneplus-enchilada.dtb";
  boot.loader.systemd-boot.extraFiles."${config.hardware.deviceTree.name}" = "${config.hardware.deviceTree.package}/${config.hardware.deviceTree.name}";
  boot.kernelParams = [
    "console=ttyMSM0,115200"
    "console=tty0"

    "dtb=/${config.hardware.deviceTree.name}"
    "earlycon=efifb"
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  # mobile.boot.enableDefaultSerial = true;
  # mobile.boot.serialConsole = "";

  mobile.device.firmware = lib.mkForce enchilada_firmware;
  hardware.firmware = lib.mkBefore [
    enchilada_firmware
  ];

  system.stateVersion = "24.05";
}
