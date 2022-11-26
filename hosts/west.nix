inputs@{ lib, config, pkgs, ... }:
let

secrets = import ../secrets.nix;

in
{
#TODO move common things away
#and hardware things to hardware
    imports =
        [
        ./west_hardware.nix
            ./modules/fonts.nix
            ./modules/nix.nix
            ./modules/packages.nix
            ./modules/audio.nix
            ./modules/ssh.nix
        ];

    nix.settings.cores = 3;
    hardware.opengl = {
            enable = true;
            extraPackages = with pkgs; [
            libglvnd
            vaapiVdpau
            libvdpau-va-gl
            nvidia-vaapi-driver
            ];
        };

        time.timeZone = secrets.timeZone;

#TODO Move router away
#TODO dns, ipv6, better ruleset
#This will require running a VM.

    boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
    };
    networking = {
        nameservers = [ "8.8.8.8" ];
        #no iptables
        firewall.enable = false;
        nftables.enable = true;
        nftables.ruleset = ''
            flush ruleset
            define LAN_SPACE = 10.0.0.0/24

            table netdev filter {
                chain ingress{
                    type filter hook ingress devices = { enp3s0, enp4s6 } priority -500;
                    
                    tcp flags & (fin|syn) == (fin|syn) drop
                    tcp flags & (syn|rst) == (syn|rst) drop
                    tcp flags & (fin|syn|rst|psh|ack|urg) == (fin|syn|rst|psh|ack|urg) drop
                    tcp flags & (fin|syn|rst|psh|ack|urg) == 0 drop
                    tcp flags syn tcp option maxseg size 0-500 drop

                    ip saddr 10.0.0.1 drop
                    ip6 saddr fe00::1 drop

                    fib saddr . iif oif missing drop
                }
                chain ingress_wan{
                    type filter hook ingress device enp4s6 priority -500;

                    ip protocol icmp limit rate 5/second accept
                    ip protocol icmp counter drop
                    ip6 nexthdr icmpv6 limit rate 5/second accept
                    ip6 nexthdr icmpv6 counter drop
                }
            }

            table ip global {
                chain in_wan{
                    ip protocol icmp icmp type {destination-unreachable, echo-request, time-exceeded, parameter-problem} accept
                }
                #absolute trust
                    chain in_lan {
                        accept
                    }
                chain inbound {
                    type filter hook input priority 0; policy drop;
                    tcp flags & syn != syn ct state new drop
                    ct state vmap {established : accept, related : accept, invalid : drop}
                    iifname vmap {lo : accept, enp3s0 : jump in_lan, enp4s6 : jump in_wan}
                    tcp dport {${secrets.sshPortsString}} accept
                }
                chain forward {
                    type filter hook forward priority 0; policy drop;
                    ct state vmap { established : accept, related : accept, invalid : drop }
                    iifname enp3s0 accept
                }
                chain postrouting {
                    type nat hook postrouting priority 100; policy accept;
                    ip saddr $LAN_SPACE oifname enp4s6 masquerade
                }
            }
        '';
        interfaces = {
            enp3s0 = {
                useDHCP = false;
                ipv6.addresses = [{
                    address = "fd00::1";
                    prefixLength = 48;
                }];
                ipv4.addresses = [{
                    address = "10.0.0.1";
                    prefixLength = 24;
                }];
            };
            enp4s6 = {
                useDHCP = true;
            };
        };
    };
    services.dhcpd4 = {
        enable = true;
        interfaces = ["enp3s0"];
        extraConfig = ''
        option routers 10.0.0.1;
        option domain-name-servers 8.8.8.8, 8.8.4.4;
        option domain-name "local";
        subnet 10.0.0.0 netmask 255.255.255.0 {
            range 10.0.0.2 10.0.0.10;
        }
        '';
    };

    networking.hostName = secrets.hostName;
    networking.hostId = secrets.hostId;
    networking.networkmanager.enable = true;

services.avahi = {
        enable = true;
        interfaces = ["enp3s0"];
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

    services.xserver.videoDrivers = ["nvidia"];
    services.xserver = {
        enable = true;

        windowManager.i3 = {
            enable = true;
        };
        displayManager.defaultSession = "none+i3";
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
        extraGroups = [ "realtime" "pipewire" "jackaudio" "wheel" "libvirt" "audio" ];
        shell = pkgs.zsh;
        initialHashedPassword = secrets.userHashedPassword;
        packages = with pkgs; [
            libva
            libva-utils
            vdpauinfo
        ];
    };

#TODO move to their respective places
#And understand what should go where.
#Do after finishing other parts.
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
