inputs @ {
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
}:
#This would have not been made without Chayleaf, sdm845-mainline contributors, Renegade Project, mobile-nixos contributors, and more...
{
  imports = [./usb.nix ./buffyboard.nix];
  #TODO: finishing steps
  #1. Installer - add qemu flake with configurable script
  #2. Test that North provides DHCP for USB connection, maybe configure masquerading and forwarding
  #3. Calls (test with my sim cards) (look into chayleaf's config for q6voiced)
  #4. Cellular connection (having troubles with this right now)
  #5. ADB - make work alongside NCM
  #6. GPS
  #7. Camera (might need to update to the latest kernel for that)
  #8. Installer - test that the minimal system builds in appropriate time

  #TODO: hardware-caused issues:
  #1. systemd-boot lists all the configurations in a single list, I don't like that
  #2. systemd-boot has garbage at the bottom of the output
  #3. No calls receiving while in suspend
  #4. Fingerprint sensor not available
  #5. No providing power over USB
  #6. Main camera unavailable
  #TODO: what can work but I have not touched properly
  #1. WWAN
  #2. GPS
  #3. Second rear camera
  #4. NFC
  #5. Programmable alert slider

  config = {
    hlk = {
      common.enable = true;
      sshd = {
        default.enable = true;
        rootKeysFrom = secrets.north.authorizedKeyFiles;
      };
      audio = {
        default.enable = false;
        lowLatency.enable = false;
        desktop.enable = false;
      };
      defaultFilesystems = true;
      stateRemoval.enable = true;
      backup.enable = true;
      mainUser = {
        enable = true;
        userName = "imikoy";
        userConfig = {
          keepass.enable = true;
          firefox.default.enable = true; #TODO: mobile-friendly config
          nheko.enable = true;
          #krita.enable = true;
          #fcitx.enable = true;
          common.enable = true;
          nvim.default.enable = true;
          gpg.default.enable = true;
          cli = {
            core.enable = true;
            extra.enable = true;
            shell = "zsh"; #TODO: fish?
            starship.enable = true;
          };
          graphical.windowSystem = "wayland_mobile";

          network = {
            manager = "networkmanager";
            hostName = "north";
          };
        };
        extraHmConfig = {
          home.persistence."/state/home/imikoy" = {
            allowOther = true;
            directories = [
              ".config/pulse" #TODO: when creating audio module with pulseaudio option, move this to the new module
              ".purple" # chatty
              ".local/share/evolution" # calendar, email, address book
              ".local/share/calls" # calls things
            ];
            files = [
              #NOTE: phosh replaces the symlink with a file, wiping the settings
              #".config/dconf/user" #gnome settings
            ];
          };
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

    hardware.pulseaudio.enable = lib.mkForce true;
    #TODO: attempt to do pipewire?
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

    programs.calls.enable = true;
    environment.systemPackages = with pkgs; [
      # IM and SMS
      chatty
    ];

    #TODO: should restart when usb0 is connected
    #(using udev)
    #RNDIS/NCM DHCP server to give a functionally-static IP to the PC
    services.kea.dhcp4 = {
      enable = true;
      settings = {
        valid-lifetime = 4000;
        renew-timer = 1000;
        rebind-timer = 2000;
        interfaces-config.interfaces = ["usb0"];
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          #it is stateless anyway
          #persist = true;
          persist = false;
          type = "memfile";
        };
        subnet4 = [
          {
            id = 1;
            subnet = "172.16.42.0/24";
            pools = [{pool = "172.16.42.2 - 172.16.42.2";}];
            interface = "usb0";
          }
        ];
      };
    };

    # systemd.services.q6voiced = {
    #   description = "QDSP6 driver daemon";
    #   after = ["ModemManager.service" "dbus.socket"];
    #   wantedBy = ["ModemManager.service"];
    #   requires = ["dbus.socket"];
    #   serviceConfig.ExecStart = "${pkgs.q6voiced}/bin/q6voiced hw:0,6";
    # };

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
