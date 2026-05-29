{
  pkgsPrev,
  pkgsFinal,
  lib,
  flake_inputs,
  ...
}:
let
  pkgsNoCross = import flake_inputs.nixpkgs { localSystem.system = "aarch64-linux"; };
in
rec {
  linux_spacewar = import ./kernel.nix {
    pkgs = pkgsPrev;
    inherit lib;
  };
  #TODO: firmware

  uboot_spacewar =
    (pkgsPrev.buildUBoot {
      version = "unstable-2026-03-23";
      #TODO: apply patch
      src = pkgsPrev.fetchFromGitHub {
        owner = "mainlining";
        repo = "u-boot";
        rev = "7b0f54d245216e100589d4897e173d983cd61778";
        hash = "sha256-O+G/WXjWY3nQkfkWkAxBTc0gcavePwu1ixKJtIV0QMk=";
      };
      extraPatches = [ ./uboot_fixes.patch ];
      defconfig = "qcom_defconfig qcom-phone.config";
      makeFlags = [
        "DEVICE_TREE=qcom/sm7325-nothing-spacewar"
        "CONFIG_CMD_BOOTEFI=y"
        "CONFIG_EFI_LOADER=y"
        #TODO: could be made conditional based on crossSystem
        "CROSS_COMPILE=aarch64-unknown-linux-gnu-"
      ];
      extraMeta.platforms = [ "aarch64-linux" ];
      filesToInstall = [
        "u-boot-nodtb.bin"
        "u-boot-dtb.bin"
        "u-boot.dtb"
      ];
    }).overrideAttrs
      (
        final: prev: {
          nativeBuildInputs = prev.nativeBuildInputs ++ [ pkgsPrev.xxd ];
        }
      );

  ubootImage_spacewar = pkgsPrev.stdenvNoCC.mkDerivation {
    name = "u-boot-spacewar.bin";
    nativeBuildInputs = [
      pkgsNoCross.android-tools
    ];
    src = uboot_spacewar;
    dontBuild = true;
    dontFixup = true;
    installPhase = ''
      mkbootimg \
        --header_version 3 \
        --kernel u-boot-dtb.bin \
        -o "$out"
    '';
  };
}
