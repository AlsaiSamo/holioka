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

  alsa-ucm-conf-op = pkgsPrev.stdenvNoCC.mkDerivation {
    pname = "alsa-ucm-conf-enchilada";
    version = "unstable-2022-12-08";
    src = pkgsPrev.fetchFromGitLab {
      owner = "sdm845-mainline";
      repo = "alsa-ucm-conf";
      rev = "aaa7889f7a6de640b4d78300e118457335ad16c0";
      hash = "sha256-2P5ZTrI1vCJ99BcZVPlkH4sv1M6IfAlaXR6ZjAdy4HQ=";
    };
    installPhase = ''
      substituteInPlace ucm2/lib/card-init.conf --replace '"/bin' '"/run/current-system/sw/bin'
      mkdir -p "$out"/share/alsa/ucm2/{OnePlus,conf.d/sdm845,lib}
      mv ucm2/lib/card-init.conf "$out/share/alsa/ucm2/lib/"
      mv ucm2/OnePlus/enchilada "$out/share/alsa/ucm2/OnePlus/"
      ln -s ../../OnePlus/enchilada/enchilada.conf "$out/share/alsa/ucm2/conf.d/sdm845/oneplus-OnePlus6-Unknown.conf"
    '';
    # to overwrite card-init.conf
    meta.priority = -10;
  };

  q6voiced = pkgsPrev.stdenv.mkDerivation {
    pname = "q6voiced";
    version = "unstable-2022-07-08";
    src = pkgsPrev.fetchFromGitLab {
      owner = "postmarketOS";
      repo = "q6voiced";
      rev = "736138bfc9f7b455a96679e2d67fd922a8f16464";
      hash = "sha256-7k5saedIALHlsFHalStqzKrqAyFKx0ZN9FhLTdxAmf4=";
    };
    buildInputs = with pkgsPrev; [dbus tinyalsa];
    nativeBuildInputs = with pkgsPrev; [pkg-config];
    buildPhase = ''cc $(pkg-config --cflags --libs dbus-1) -ltinyalsa -o q6voiced q6voiced.c'';
    installPhase = ''install -m555 -Dt "$out/bin" q6voiced'';
    meta.license = lib.licenses.mit;
  };
}
