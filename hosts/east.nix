inputs@{ lib, config, pkgs, ... }:
let

secrets = import ../secrets.nix;

#Configuration for Thinkpad A275 (TFT 1366x768 no-touch, no keyboard backlight, no smartcard reader, no fingerprint reader, has TPM 2, no WWAN but with SIM slot)
#TODO scripts for power saving and a different polybar config
#buy both batteries, 16G RAM stick and replace the screen

in
{
    imports =
        [
        ./east_hardware.nix
            ./modules/fonts.nix
            ./modules/nix.nix
            ./modules/packages.nix
            ./modules/audio.nix
            #./modules/ssh.nix
        ];

    nix.settings.cores = 3;
    hardware.opengl = {
            enable = true;
            extraPackages = with pkgs; [
#TODO this is AMD only platform
            ];
        };

    hardware.trackpoint = {
      enable = true;
    };
    services.xserver.libinput = {
            enable = true;
            touchpad = {
                    naturalScrolling = true;
                };
    };

        time.timeZone = secrets.timeZone;

    networking = {
        nameservers = [ "8.8.8.8" ];
        #no iptables
        firewall.enable = false;
#TODO basic firewall
        nftables.enable = true;
    };

    networking.hostName = "hlkeast";
    networking.hostId = secrets.hostId;
    networking.networkmanager.enable = true;
    programs.nm-applet.enable = true;

#unneeded for now
services.avahi = {
        enable = false;
        #interfaces = ["enp3s0"];
        publish = {
                enable = true;
                domain = true;
                addresses = true;
                userServices = true;
            };
    };

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        font = "Lat2-Terminus16";
#     keyMap = "us";
        useXkbConfig = true; # use xkbOptions in tty.
    };

    programs.fuse.userAllowOther = true;

    services.xserver.videoDrivers = ["amdgpu"];
    services.xserver = {
        enable = true;

        windowManager.i3 = {
            enable = true;
        };
        displayManager.defaultSession = "none+i3";
        displayManager.autoLogin = {
                enable = true;
                user = "imikoy";
            };
        displayManager.sddm = {
            enable = true;
            autoNumlock = true;
        };
    };

    services.xserver.layout = "us,ru";

    users.mutableUsers = false;
    users.users.root.initialHashedPassword = secrets.rootHashedPassword;

    programs.zsh.enable = true;

    security.polkit.enable = true;
    users.users.imikoy = {
        isNormalUser = true;
        extraGroups = [ "realtime" "pipewire" "jackaudio" "wheel" "libvirt" "audio" "video"];
        shell = pkgs.zsh;
        initialHashedPassword = secrets.userHashedPassword;
        packages = with pkgs; [
            libva
            libva-utils
            vdpauinfo
        ];
    };

    environment.systemPackages = with pkgs; [
        pciutils
#       pamixer
#^^^^ Breaks wireplumber
            psmisc
            vim
            wget
            xclip
            nmap
            tcpdump
            wireshark
            glxinfo
            pinentry
#^^^^^ needed for GPG
    ];
    programs.light.enable = true;

    home-manager = {
        users.imikoy = import ../users/imikoy.nix {inherit config lib pkgs;};
        extraSpecialArgs = {};
        sharedModules = [
            inputs.hm_im
        ];
    };

    environment.persistence."/state" = {
        files = [
            "/etc/machine-id"
        ];
    };

    system.stateVersion = "22.05";
}
