inputs @ {
  lib,
  config,
  pkgs,
  secrets,
  extra,
  modulesPath,
  ...
}: {
  #TODO: credit Chayleaf
  #TODO:
  #1. Graphical setup
  #2. Audio setup (pulseaudio, then attempt pipewire)
  #3. Network setup
  hlk = {
    #TODO: review the common stuff so that I can enable what I can
    common.enable = false;
    audio = {
      default.enable = false;
      lowLatency.enable = false;
      desktop.enable = false;
    };
    defaultFilesystems = true;
    stateRemoval.enable = false;
    backup.enable = true;
    network = {
      #TODO: rewrite network module because op6 needs netowrkmanager
      default.enable = false;
      desktop.enable = false;
      hostName = "north";
    };
    #TODO: rewrite to usermodules, now
    mainUser = {
      #TODO: enable the user
      #TODO: systemd stuff in hm throws error?
      default.enable = false;
      extraUserConfig.hlk = {
        #TODO: enable only some things
        emacs.default.enable = false;
        games = {
          osu.state.enable = false;
          xonotic.state.enable = false;
        };
        krita.enable = false;
        vmTools.enable = false;
        # graphical.windowSystem = "wayland";
        graphical.windowSystem = "none";
        wine.enable = false;
      };
    };
  };

  #TODO: look through my modules and disable stuff

  #Networking
  networking = {
    hostName = secrets.north.hostName;
    hostId = secrets.north.hostId;
    #TODO: enable after confirming boot
    #networkmanager.enable = true;
  };
  users.mutableUsers = false;
  users.groups.imikoy.gid = 1000;
  users.users.imikoy = {
    uid = 1000;
    hashedPassword = secrets.common.userHashedPassword;
    #user's key always allows accessing the user
    openssh.authorizedKeys.keyFiles = [../../secrets/imikoy.pub];
    isNormalUser = true;
    group = "imikoy";
    shell = pkgs.zsh;
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

  #TODO: do this after confirming boot
  # systemd.network.links."40-wlan0" = {
  #   matchConfig.OriginalName = "wlan0";
  #TODO: get mac address of the phone's wireless
  #linkConfig.MACAddressPolicy = "none";
  #linkConfig.MACAddress = config.phone.mac;
  # };

  #TODO: enable after confirming boot
  # hardware.sensor.iio.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
  #TODO: check if pipewire works after confirming pulseaudio
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

  services.tlp.enable = true;
  programs.calls.enable = true;
  environment.systemPackages = with pkgs; [
    # IM and SMS
    chatty
  ];

  services.upower = {
    enable = true;
    percentageLow = 20;
    percentageCritical = 10;
    percentageAction = 5;
    criticalPowerAction = "PowerOff";
  };

  #TODO: move buffyboard to its own module
  #NOTE: taken from Chayleaf
  boot.initrd.kernelModules = ["uinput" "evdev"];
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.buffyboard}/bin/buffyboard
    cp -a ${pkgs.libinput.out}/share $out/
  '';
  boot.initrd.extraUdevRulesCommands = ''
    cp -v ${config.systemd.package}/lib/udev/rules.d/60-input-id.rules $out/
    cp -v ${config.systemd.package}/lib/udev/rules.d/60-persistent-input.rules $out/
    cp -v ${config.systemd.package}/lib/udev/rules.d/70-touchpad.rules $out/
  '';
  boot.initrd.preLVMCommands = ''
    mkdir -p /nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-${pkgs.libinput.name}/
    ln -s "$(dirname "$(dirname "$(which buffyboard)")")"/share /nix/store/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-${pkgs.libinput.name}/
    buffyboard 2>/dev/null &
  '';
  boot.initrd.postMountCommands = ''
    pkill -x buffyboard
  '';
  systemd.services.buffyboard = {
    description = "buffyboard";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.buffyboard}/bin/buffyboard";
      Restart = "always";
      RestartSec = "1";
    };
  };
  security.sudo.extraRules = [
    {
      groups = ["users"];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl stop buffyboard";
          options = ["SETENV" "NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl start buffyboard";
          options = ["SETENV" "NOPASSWD"];
        }
      ];
    }
  ];

  system.stateVersion = "24.11";
}
