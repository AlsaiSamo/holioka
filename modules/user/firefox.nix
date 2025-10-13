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
  myFirefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
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
            # DefaultDownloadDirectory = "\${home}/Downloads";
          };
          profiles."alsaisamo" = {
            search.default = "ddg";
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
        home.persistence."/state/home/${userName}" = {
          files = [ ".config/tridactyl/tridactylrc" ];
          directories = [
            #Has the profile
            ".mozilla/firefox"
            #".cache/mozilla"
            #Keepassxc
            ".mozilla/native-messaging-hosts"
          ];
        };
        home.persistence."/local_state/home/${userName}" = {
          directories = [ ".cache/mozilla" ];
        };
      }
    #nixos
    else
      { };
}
