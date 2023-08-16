{ config, lib, pkgs, ... }@inputs:
#This only sets up autogeneration of the keys
{
  services.openssh = {
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
}
