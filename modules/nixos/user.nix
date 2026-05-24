{
  config,
  lib,
  pkgs,
  secrets,
  hmModules,
  hmOverlay,
  #flake_inputs,
  ...
}@inputs:
#Main user of the machine.
#Each machine typically has only one user and so has only one instance of hm usage.
#The user has a home-manager config that cannot change nixos config
#but is reliant on it.
#Workaround: add config options with identical options tree to both nixos
#and hm and set the same config values on both sides.
let
  cfg = config.hlk.mainUser;
in
{
  options = {
    hlk.mainUser = {
      enable = lib.mkEnableOption "enable machine's primary user";
      userName = lib.mkOption {
        default = "imikoy";
        description = "Name of machine's primary user";
        type = lib.types.str;
      };
      #Config applied to both nixos and hm, through userModules
      userConfig = lib.mkOption {
        default = { };
        description = "Main user's config";
        type = lib.types.attrs;
      };
      extraHmConfig = lib.mkOption {
        default = { };
        description = "Extra home-manager config";
        type = lib.types.attrs;
      };
      stateVersion = lib.mkOption {
        default = "25.05";
        description = "Version of home-manager state";
        type = lib.types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        users.mutableUsers = false;
        users.groups.${cfg.userName}.gid = 1000;
        users.users.${cfg.userName} = {
          uid = 1000;
          hashedPassword = secrets.common.userHashedPassword;
          #user's key always allows accessing the user
          openssh.authorizedKeys.keyFiles = [ ../../secrets/${cfg.userName}.pub ];
          isNormalUser = true;
          group = cfg.userName;
          extraGroups = [
            "wheel"
            #needed to connect to seatd socket
            "seat"
            #needed for pipewire
            #NOTE: not recommended for multiuser setups, but this isn't a multiuser setup anyways
            # "audio"
            # "video"
          ];
        };
        security.pam.loginLimits = [
          {
            domain = "*";
            item = "nofile";
            type = "hard";
            value = "1048576";
          }
          {
            domain = "*";
            item = "nofile";
            type = "soft";
            value = "65536";
          }
        ];
        services.getty.autologinUser = cfg.userName;
        home-manager = {
          useUserPackages = false;
          useGlobalPkgs = false;
          verbose = true;
          extraSpecialArgs = {
            inherit secrets;
            userName = cfg.userName;
          };
          users.${cfg.userName} = lib.mkMerge [
            {
              imports = hmModules;
              _hlk_auto = cfg.userConfig;
              home.stateVersion = cfg.stateVersion;
              programs.home-manager.enable = true;
              nixpkgs.overlays = hmOverlay;
            }
            cfg.extraHmConfig
          ];
        };
      }
      {
        _module.args.userName = cfg.userName;
        _hlk_auto = cfg.userConfig;
      }
    ]
  );
}
