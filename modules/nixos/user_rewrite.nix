{
  config,
  lib,
  pkgs,
  secrets,
  hmModules,
  hmOverlay,
  #flake_inputs,
  ...
} @ inputs:
#Main user of the machine.
#Each machine typically has only one user and so has only one instance of hm usage.
#The user has a home-manager config that cannot change nixos config
#but is reliant on it.
#Workaround: add config options with identical options tree to both nixos
#and hm and set the same config values on both sides.
#TODO: when ddone, remove old mainUser module and rename this one.
let
  cfg = config.hlk.mainUserRewrite;
in {
  options = {
    hlk.mainUserRewrite = {
      enable = lib.mkEnableOption "enable machine's primary user";
      userName = lib.mkOption {
        default = "imikoy";
        description = "Name of machine's primary user";
        type = lib.types.str;
      };
      #Config applied to both nixos and hm, through userModules
      userConfig = lib.mkOption {
        default = {};
        description = "Main user's config";
        type = lib.types.attrs;
      };
      #TODO: make into a module
      extraHmConfig = lib.mkOption {
        default = {};
        description = "Extra home-manager config";
        type = lib.types.attrs;
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
          openssh.authorizedKeys.keyFiles = [../../secrets/${cfg.userName}.pub];
          isNormalUser = true;
          group = cfg.userName;
          extraGroups = [
            "wheel"
          ];
        };
        services.kmscon.autologinUser = cfg.userName;
        home-manager = {
          useUserPackages = false;
          useGlobalPkgs = false;
          verbose = true;
          extraSpecialArgs = {
            #TODO: remove this?
            #inherit flake_inputs;
            inherit secrets;
            userName = cfg.userName;
          };
          users.${cfg.userName} = lib.mkMerge [
            {
              imports = hmModules;
              _hlk_auto = cfg.userConfig;
              home.stateVersion = "23.11";
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
