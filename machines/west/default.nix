{
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
}@inputs:
{
  hlk = {
    common.enable = true;
    defaultFilesystems = true;
    musicDataset.enable = true;
    projectsDataset.enable = true;
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

    mainUser = {
      enable = true;
      userName = "imikoy";
      userConfig = {
        common.enable = true;
        graphical.desktopVariant = "wayland";
        emacs.default.enable = true;
        games = {
          osu.state.enable = false;
          xonotic.enable = true;
          xonotic.state.enable = true;
          terraria.state.enable = true;
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
        comms = {
          nheko.enable = true;
          telegram.enable = true;
          discord.enable = true;
        };
        keepass.enable = true;
        steam.enable = true;
      };
      extraHmConfig = {
        wayland.windowManager.sway.config = {
          output = {
            # built-in screen
            "Lenovo Group Limited 0x40BA Unknown" = {
              #TODO: reposition due to setup change.
              pos = "1920 860";
            };
            #right side vertical screen
            "Philips Consumer Electronics Company PHL 240V5A UK01614009987" = {
              transform = "270";
              pos = "3840 0";
            };
            #left side drawing monitor
            "HUN GT-191 Unknown" = {
              #TODO: reposition due to setup change.
              pos = "0 860";
            };
          };
          input = {
            # Huion GT-191 V1 tablet input
            "9580:110:HID_256c:006e" = {
              map_to_output = "'HUN GT-191 Unknown'";
              # calibration_matrix = "0.99429023 0.0019176602 0.0047730505 -0.0016639531 0.9844543 0.009848058";
              calibration_matrix = "0.9961097 0.005224526 0.002898991 0.007392943 0.9870372 0.0025025606";
            };
          };
        };
      };
    };
  };
  environment.persistence."/local_state".users.imikoy = {
    directories = secrets.west.persistLocalHomeDirs;
  };

  specialisation."work" = {
    inheritParentConfig = true;
    configuration = {
      hlk.mainUser.userConfig = {
        work.enable = true;
        steam.enable = lib.mkForce false;
        games.terraria.state.enable = lib.mkForce false;
        comms.nheko.enable = lib.mkForce false;
      };
      hlk.projectsDataset.enable = lib.mkForce false;
      hlk.datasetPrefix = "work";
    };
  };
  #TODO: specialisation for streaming
  #TODO: blacklist the webcam in streaming setup

  services.upower = {
    enable = true;
    percentageLow = 20;
    percentageCritical = 10;
    percentageAction = 5;
    allowRiskyCriticalPowerAction = true;
    criticalPowerAction = "Suspend";
  };

  # protracted imikoy's war against adhd
  networking.hosts = {
    "127.0.0.1" = [
      "youtube.com"
      "www.youtube.com"
    ];
  };

  nix.extraOptions = ''
    extra-platforms = aarch64-linux
  '';
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "25.11";
}
