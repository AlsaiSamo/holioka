{
  config,
  lib,
  pkgs,
  secrets,
  hmModules,
  flake_inputs,
  ...
} @ inputs: let
  cfg = config.hlk.mainUser;
in {
  #Primary user is the one to autoLogin everywhere
  options = {
    hlk.mainUser = {
      default.enable = lib.mkEnableOption "default configuration for machine's primary user";
      userName = lib.mkOption {
        default = "imikoy";
        description = "Name of machine's primary user";
        type = lib.types.str;
      };
      hmProfile = lib.mkOption {
        default = "${cfg.userName}Full";
        description = "Home Manager profile";
        type = lib.types.str;
      };
    };
  };
  #TODO: load the home manager stuff from here
  config = {
    users.mutableUsers = false;
    users.groups.imikoy.gid = 1000;
    users.users.${cfg.userName} = {
      hashedPassword = secrets.common.userHashedPassword;
      isNormalUser = true;
      group = cfg.userName;
      shell = pkgs.zsh;
      extraGroups = ["wheel" "realtime" "pipewire" "jackaudio" "libvirt" "audio" "video"];
    };
    security.pam.loginLimits = [
      {
        domain = cfg.userName;
        type = "hard";
        item = "nofile";
        value = "65535";
      }
      {
        domain = cfg.userName;
        type = "soft";
        item = "nofile";
        value = "8191";
      }
      {
        domain = "@audio";
        type = "-";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "@audio";
        type = "-";
        item = "rtprio";
        value = "95";
      }
    ];

    services.xserver.displayManager.autoLogin.user = cfg.userName;
    services.kmscon.autologinUser = cfg.userName;

    home-manager = {
      useUserPackages = false;
      useGlobalPkgs = false;
      verbose = true;
      extraSpecialArgs = {
        inherit flake_inputs;
        inherit secrets;
      };
    };
    home-manager.users.${cfg.userName} =
      import ../../users/${cfg.hmProfile}.nix
      {
        inherit flake_inputs hmModules pkgs config lib;
        userName = cfg.userName;
      };
  };
}
