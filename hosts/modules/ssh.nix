{lib, pkgs, ...}:
let

secrets = import ../../secrets.nix;

in
{
    services.openssh = {
        enable = true;
        passwordAuthentication = false;
        kbdInteractiveAuthentication = false;
        openFirewall = true;
        ports = secrets.sshPorts;
        logLevel = "VERBOSE";
        hostKeys = [
            {
                bits = 4096;
                openSSHFormat = true;
                path = "/state/secrets/ssh/ssh_host_rsa_key";
                type = "rsa";
            }
            {
                openSSHFormat = true;
                path = "/state/secrets/ssh/ssh_host_ed25519_key";
                type = "ed25519";
            }
        ];
        forwardX11 = false;
        startWhenNeeded = false;
        #I currently do not need root login.
        permitRootLogin = "no";
    };
    users.users.imikoy.openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDD3wGR8NNWm/RjHOMOXIrpgc/KC2pv8ZJXyNpPTo7LPTKQqmJprPUtGtU4cCuw1T//ujjKyW04FH6pReM7rwZ0Lj97lxc2ldY6zSrRwKhFEKlHTmhfGsLD0TV4aBV3UvZcAl1Tn24zOVSGnUoREQRKCKoDNI2tNZt4FRbY9yceu03HhVb6GQJJHayvvzc37eKaAiRsFNATwcvklnPPKgDLODj04n1c7cgZ206xKcLj7xCFNfmqjuXIoTgZ2aO3LZNIHlMPmfmWJbW29rBLSeiW6b6PPlfcXlMf43fwY/w3DqvBB3hcfCcbrmrReiBHe0HP0FOAkh5ImWZ/x/BU+Om8OhKc4w1H6Jbw5h+2fcHHhF+GGOWJp/zrub+nJDybmH3Kr0wTFvAthLG/qlkdFiStnOHyaCyOBKr+EsKuTlNaW+bveVe43/p1u5PfW0c1PcSNu40d/+D5Q21VuoJ8Sr0qQU35u+iouwoiY0c0lLebmpzhfLR2DB++ZJSVCatzZHk= (none)"
    ];
    services.fail2ban = {
        enable = true;
        maxretry = 5;
        banaction = "nftables-multiport";
        banaction-allports = "nftables-allport";
        packageFirewall = pkgs.nftables;
    };
}
