{
  config,
  lib,
  pkgs,
  ...
} @ inputs:
#TODO: currently unused, rewrite
#This only sets up autogeneration of the keys
let
  cfg = config.hlk.sshd;
in {
  options = {
    hlk.sshd = {
      default.enable = lib.mkEnableOption "default SSHD configuration";
    };
  };
  config = lib.mkIf cfg.default.enable {
    #TODO: make this properly
    services.openssh = lib.warnIf cfg.default.enable "SSHD configuration is yet to be overhauled" {
      enable = true;
      settings = {
        #Currently I am going to rely on root
        #PermitRootLogin =
        PasswordAuthentication = false;
        LogLevel = "VERBOSE";
        KbdInteractiveAuthentication = false;
      };
      hostKeys = [
        {
          bits = 4096;
          path = "/state/secrets/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/state/secrets/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
    #TODO: fail2ban
  };
}
