{
  config,
  lib,
  pkgs,
  ...
} @ inputs: let
  cfg = config.hlk.sshd;
in {
  options = {
    hlk.sshd = {
      default.enable = lib.mkEnableOption "default SSHD configuration";
      rootKeysFrom = lib.mkOption {
        example = "secrets.west.authorizedKeyFiles";
        description = "Where to take the root's keyfiles from";
        type = lib.types.listOf lib.types.path;
      };
    };
  };
  config = lib.mkIf cfg.default.enable {
    services.openssh = {
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
    services.fail2ban = {
      enable = true;
      bantime = "30m";
    };
    users.users.root.openssh.authorizedKeys.keyFiles = cfg.rootKeysFrom;
  };
}
