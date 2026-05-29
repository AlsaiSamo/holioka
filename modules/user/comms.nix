select_user:
{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
#Communications - telegram, matrix (nheko client).
let
  cfg = config._hlk_auto.comms;
  options._hlk_auto.comms = {
    nheko.enable = lib.mkEnableOption "nheko matrix client";
    telegram.enable = lib.mkEnableOption "telegram desktop client";
    #TODO: dorion currently doesn't support webrtc properly
    discord.enable = lib.mkEnableOption "discord client (legcord)";
  };
in
{
  inherit options;
  config =
    if
      select_user
    #hm
    then
      lib.mkMerge [
        (lib.mkIf cfg.nheko.enable {
          #broken, deprecated, relied upon by everyone 👍 matrix is a terrible, broken ecosystem
          nixpkgs.config.permittedInsecurePackages = [
            "olm-3.2.16"
          ];
          programs.nheko.enable = true;
        })
        (lib.mkIf cfg.telegram.enable {
          home.packages = [ pkgs.telegram-desktop ];
        })
        (lib.mkIf cfg.discord.enable {
          home.packages = [ pkgs.legcord ];
        })
      ]
    #nixos
    else
      lib.mkMerge [
        (lib.mkIf cfg.nheko.enable {
          environment.persistence."/state".users.${userName} = {
            directories = [
              ".cache/nheko"
              ".config/nheko"
              ".local/share/nheko"
            ];
          };
        })
        (lib.mkIf cfg.telegram.enable {
          environment.persistence."/state".users.${userName} = {
            directories = [
              ".local/share/TelegramDesktop"
            ];
          };
          environment.persistence."/local_state".users.${userName} = {
            directories = [
              #NOTE: this bindmounts to both /home/imikoy/... and /state/home/imikoy/..., funny
              #(same with the legcord cache down below)
              ".local/share/TelegramDesktop/tdata/user_data/cache"
              ".local/share/TelegramDesktop/tdata/user_data/media_cache"
            ];
          };
        })
        (lib.mkIf cfg.discord.enable {
          environment.persistence."/state".users.${userName} = {
            directories = [
              ".config/legcord"
            ];
          };
          environment.persistence."/local_state".users.${userName} = {
            directories = [
              ".config/legcord/Cache"
            ];
          };
        })
      ];
}
