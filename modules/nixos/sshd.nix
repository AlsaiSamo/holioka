{
  config,
  lib,
  pkgs,
  ...
} @ inputs:
let
  cfg = config.hlk.sshd;
in {
  options = {
    hlk.sshd = {
      default.enable = lib.mkEnableOption "default SSHD configuration";
    };
  };
  config = {
    services.openssh = lib.mkIf cfg.default.enable {
      enable = true;
      openFirewall = true;
      settings = {
#Root login via pkey permitted
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        LogLevel = "VERBOSE";
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
      };
#Autogeneration of keys
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
