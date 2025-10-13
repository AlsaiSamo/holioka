{
  pkgsPrev,
  pkgsFinal ? pkgsPrev,
  lib,
  flake_inputs,
}:
{
  #TODO: update buffyboard
  #it will come with its own systemd service that allows it to only run in tty
  # buffyboard = pkgsPrev.stdenv.mkDerivation {
  #   pname = "buffyboard";
  #   version = "unstable-2023-11-20";
  #   # version = "unstable-2025-05-07";

  #   src = pkgsPrev.fetchFromGitLab {
  #     domain = "gitlab.postmarketos.org";
  #     owner = "postmarketOS";
  #     repo = "buffybox";
  #     # this is updated buffyboard rev
  #     # rev = "426f849b727afa150244a7441e8eb67cb551285e";
  #     # hash = "sha256-nlyN+YBuguZ5YlhRji4AMja0zY+YsuM1xtaq3NYPTL4=";

  #     rev = "14b30c60183d98e8d0b4dadf66198e08badf631e";
  #     hash = "sha256-9wLuTAqYoFl+IAR1ixp0nHwh6jBWl+1jDPhhxqE+LHQ=";

  #     fetchSubmodules = true;
  #   };
  #   # https://gitlab.com/postmarketOS/buffybox/-/issues/1
  #   hardeningDisable = ["fortify3"];

  #   # mesonInstallFlags = ["buffyboard"];
  #   postPatch = ''
  #     cd buffyboard
  #   '';

  #   nativeBuildInputs = with pkgsPrev; [
  #     meson
  #     ninja
  #     pkg-config
  #     scdoc
  #   ];

  #   buildInputs = with pkgsPrev; [
  #     libevdev
  #     libinput
  #     libxkbcommon
  #     inih
  #   ];

  #   meta = with lib; {
  #     description = "";
  #     homepage = "https://gitlab.com/postmarketOS/buffybox/-/tree/master/buffyboard";
  #     license = licenses.gpl3Plus;
  #     maintainers = with maintainers; [imikoy];
  #     mainProgram = "buffyboard";
  #     platforms = platforms.linux;
  #   };
  # };

  #NOTE: taken from https://github.com/NixOS/nixpkgs/pull/416430/commits/5f9fa170d06b4498ab35595e868f3fda82e90540
  buffyboard = pkgsPrev.stdenv.mkDerivation (finalAttrs: {
    pname = "buffyboard";
    version = "3.3.0-unstable-2025-06-12";

    src = pkgsPrev.fetchFromGitLab {
      domain = "gitlab.postmarketos.org";
      owner = "postmarketOS";
      repo = "buffybox";
      fetchSubmodules = true; # to use its vendored lvgl
      rev = "dd30685f75f396ba9798e765c798342a5ea47370";
      hash = "sha256-l9bIcn5UkpAI6Z6W4rjj20lEAhJn+5GPaiGOVEtENhA=";
    };

    depsBuildBuild = with pkgsPrev; [
      pkg-config
    ];

    nativeBuildInputs = with pkgsPrev; [
      meson
      ninja
      pkg-config
      scdoc
    ];

    buildInputs = with pkgsPrev; [
      inih
      libdrm
      libinput
      libxkbcommon
    ];

    mesonInstallTags = [ "buffyboard" ];

    # without this, meson tries to install systemd unit into systemd derivation (which is wrong)
    # use systemd.packages nixos option
    env.PKG_CONFIG_SYSTEMD_SYSTEMD_SYSTEM_UNIT_DIR = "${placeholder "out"}/lib/systemd/system";

    strictDeps = true;

    meta = with lib; {
      description = "Suite of graphical applications for the terminal";
      homepage = "https://gitlab.postmarketos.org/postmarketOS/buffybox";
      license = licenses.gpl3Plus;
      maintainers = with lib.maintainers; [ colinsane ];
      mainProgram = "buffyboard";
      platforms = platforms.linux;
    };
  });
}
