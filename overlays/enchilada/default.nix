{
  pkgsPrev,
  pkgsFinal,
  lib,
  flake_inputs,
  ...
}: let
  inherit (flake_inputs) mobile-nixos;
  mobilePkgs = import "${mobile-nixos}/overlay/overlay.nix" pkgsFinal pkgsPrev;
in rec {
  #TODO: try to update
  linux_enchilada = import ./kernel.nix {
    pkgs = pkgsPrev;
    inherit lib;
  };

  #TODO: try to update
  enchilada_firmware = pkgsPrev.stdenvNoCC.mkDerivation {
    name = "firmware-oneplus-sdm845";
    src = pkgsPrev.fetchFromGitLab {
      owner = "sdm845-mainline";
      repo = "firmware-oneplus-sdm845";
      rev = "176ca713448c5237a983fb1f158cf3a5c251d775";
      hash = "sha256-ZrBvYO+MY0tlamJngdwhCsI1qpA/2FXoyEys5FAYLj4=";
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

  #TODO: try to update?
  uboot_enchilada =
    (pkgsPrev.buildUBoot {
      version = "unstable-2023-12-11";
      src = pkgsPrev.fetchFromGitLab {
        owner = "sdm845-mainline";
        repo = "u-boot";
        rev = "977b9279c610b862f9ef84fb3addbebb7c42166a";
        hash = "sha256-ksI7qxozIjJ5E8uAJkX8ZuaaOHdv76XOzITaA8Vp/QA=";
      };
      defconfig = "qcom_defconfig";
      makeFlags = ["DEVICE_TREE=sdm845-oneplus-enchilada" "CONFIG_CMD_BOOTEFI=y" "CONFIG_EFI_LOADER=y"];
      extraMeta.platforms = ["aarch64-linux"];
      filesToInstall = ["u-boot-nodtb.bin" "u-boot-dtb.bin" "u-boot.dtb"];
    })
    .overrideAttrs (final: prev: {
      nativeBuildInputs = prev.nativeBuildInputs ++ [pkgsPrev.xxd];
    });

  ubootImage_enchilada = pkgsPrev.stdenvNoCC.mkDerivation {
    name = "u-boot-enchilada.bin";
    nativeBuildInputs = [mobilePkgs.mkbootimg pkgsFinal.gzip];
    src = uboot_enchilada;
    dontBuild = true;
    dontFixup = true;
    installPhase = ''
      gzip u-boot-nodtb.bin
      cat u-boot.dtb >> u-boot-nodtb.bin.gz
      mkbootimg \
        --base 0x0 \
        --kernel_offset 0x8000 \
        --ramdisk_offset 0x01000000 \
        --tags_offset 0x100 \
        --pagesize 4096 \
        --kernel u-boot-nodtb.bin.gz \
        -o "$out"
    '';
  };
}
