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
    #TODO: try out dorion when 6.12.0 hits nixpkgs
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
              #TODO: persist .local/share/TelegramDesktop/tdata/user_data/{cache,media_cache} in local_state
              #(check that this will work)
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
              #TODO: check that this'll work.
              ".config/legcord/Cache"
            ];
          };
        })
      ];
}
