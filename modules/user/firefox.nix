select_user:
{
  config,
  lib,
  pkgs,
  userName,
  ...
}:
let
  cfg = config._hlk_auto.firefox;
  options._hlk_auto.firefox = {
    default.enable = lib.mkEnableOption "default Firefox configuration";
  };
  myFirefox = pkgs.wrapFirefox pkgs.librewolf-unwrapped {
    nativeMessagingHosts = [ pkgs.tridactyl-native ];
    extraPolicies = {
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      PromptForDownloadLocation = true;
      ShowHomeButton = false;
      UserMessaging = {
        WhatsNew = false;
        ExtensionRecommendation = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
      };
      DisableFeedbackCommands = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
    };
  };
in
{
  inherit options;
  config =
    if
      select_user
    #hm
    then
      lib.mkIf cfg.default.enable {
        programs.firefox = {
          enable = true;
          package = myFirefox;
          policies = {
            # NOTE: I actually use the fact that the dir has no default.
            # DefaultDownloadDirectory = "\${home}/Downloads";
          };
          profiles."alsaisamo" = {
            #NOTE: configuring search has to be disabled due to this issue
            #https://github.com/nix-community/home-manager/issues/3698
            # search.default = "ddg";
            extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
              ublock-origin
              tridactyl
              keepassxc-browser
              #firefox-color
            ];
            userChrome = ''
              .private-browsing-indicator-label {
                display: none;
              }
            '';
          };
        };
      }
    #nixos
    else
      lib.mkIf cfg.default.enable {
        environment.persistence."/state".users.${userName} = {
          files = [ ".config/tridactyl/tridactylrc" ];
          directories = [
            #Has the profile
            # ".mozilla/firefox"
            ".librewolf"
            #Keepassxc
            ".mozilla/native-messaging-hosts"
          ];
        };
        environment.persistence."/local_state".users.${userName} = {
          directories = [
            # ".cache/mozilla"
            ".cache/librewolf"
          ];
        };
      };
}
