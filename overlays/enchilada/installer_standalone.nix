{
  pkgsFinal,
  pkgsPrev,
  lib,
  flake_inputs,
  ...
}: rec {
  installer_enchilada = kernel:
    import "${pkgsPrev.path}/nixos/lib/eval-config.nix" {
      system = "aarch64-linux";
      modules = [
        (import ./installer.nix)
        {
          #TODO: overlay here to fix adbd build ( hardeningDisable = [ "zerocallusedregs"  ]; )
          nixpkgs.overlays = [
            (import "${flake_inputs.mobile-nixos}/overlay/overlay.nix")
            (import ./adbd_fix.nix)
          ];
          nixpkgs.pkgs = pkgsPrev;
        }
      ];
      #TODO: kernel has to be given from nixpkgsARM specifically
      #specialArgs = {mobile-nixos = flake_inputs.mobile-nixos; kernel = linux_enchilada;};
      specialArgs = {
        mobile-nixos = flake_inputs.mobile-nixos;
        inherit kernel;
      };
    };
  installer_filesystems = kernel: let
    installer = installer_enchilada kernel;
      in
    pkgsPrev.stdenvNoCC.mkDerivation {
      name = "installer-filesystems";
      dontBuild = true;
      dontFixup = true;
      dontUnpack = true;
      installPhase = let
        fs = builtins.mapAttrs (k: v: v.output) installer.config.mobile.generatedFilesystems;
      in
        ''
          mkdir -p "$out"
          cp -r "${fs.rootfs}"/* "$out"
          cp "${fs.boot}" "$out/boot.img"
        '';
    };
}
