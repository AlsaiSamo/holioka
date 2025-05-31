inputs @ {
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
}:
#Minimal version of configuration that is capable of wifi, RNDIS/NCM and ssh, and is also friendly to
#being built in emulator
#TODO: test that it builds and that it works as intended
{
  imports = [./usb.nix ./buffyboard.nix];

  config = {
    hlk = {
      common.enable = true;
      sshd = {
        default.enable = true;
        rootKeysFrom = secrets.north.authorizedKeyFiles;
      };
      defaultFilesystems = true;
      # stateRemoval.enable = true;
      backup.enable = true;
      mainUserRewrite = {
        enable = true;
        userName = "imikoy";
        userConfig = {
          common.enable = true;
          nvim.default.enable = true;
          gpg.default.enable = true;
          cli = {
            core.enable = true;
            extra.enable = true;
            shell = "zsh";
            starship.enable = true;
          };
          network = {
            manager = "networkmanager";
            hostName = "north";
          };
        };
        extraHmConfig = {
          #NOTE: these fail to build in aarch64 emulator
          #fails due to fish failing
          programs.direnv.enable = lib.mkForce false;
          #fails due to a timeout caused by slow emulation
          programs.atuin.enable = lib.mkForce false;
        };
      };
    };
    users.users.imikoy = {
      extraGroups = [
        "wheel"
        "realtime"
        "jackaudio"
        "libvirt"
        "libvirtd"
        # "audio"
        # "video"
        #access to serial interfaces
        "dialout"
        "networkmanager"
        "video"
        "feedbackd"
      ];
    };

    nixpkgs.config.permittedInsecurePackages = [
      "olm-3.2.16"
    ];

    services.logind.powerKey = "ignore";
    services.logind.powerKeyLongPress = "poweroff";
    hardware.sensor.iio.enable = true;

    hardware.pulseaudio.enable = lib.mkForce false;
    services.pipewire.enable = lib.mkForce false;

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id.indexOf("org.freedesktop.login1.suspend" == 0)
          || action.id.indexOf("org.freedesktop.login1.reboot" == 0)
          || action.id.indexOf("org.freedesktop.login1.power-off" == 0)
          || action.id.indexOf("org.freedesktop.inhibit") == 0)
        && subject.user == "imikoy")
        {
          return polkit.Result.YES;
        }
      });
    '';

    services.upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 10;
      percentageAction = 5;
      criticalPowerAction = "PowerOff";
    };

    environment.persistence."/state" = {
      directories = [
        "/var/lib/upower"
        "/var/lib/power-profiles-daemon"
      ];
    };

    system.stateVersion = "24.11";
  };
}
