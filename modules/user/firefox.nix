select_user: {
  config,
  lib,
  pkgs,
  userName,
  ...
}:
# Example of a userModule, copy it and fill in
let
  cfg = config._hlk_auto.firefox;
  options._hlk_auto.firefox = {
    default.enable = lib.mkEnableOption "default Firefox configuration";
  };
  myFirefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    nativeMessagingHosts = with pkgs; [pkgs.tridactyl-native];
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
in {
  inherit options;
  config =
    if select_user
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
            search.default = "DuckDuckGo";
            extensions = with pkgs.nur.repos.rycee.firefox-addons; [
              ublock-origin
              tridactyl
              keepassxc-browser
              #firefox-color
            ];
            #TODO: userChrome
            #userChrome
            #userContent
          };
        };
        home.persistence."/state/home/${userName}" = {
          files = [".config/tridactyl/tridactylrc"];
          directories = [
            #Has the profile
            ".mozilla/firefox"
            #".cache/mozilla"
            #Keepassxc
            ".mozilla/native-messaging-hosts"
          ];
        };
        home.persistence."/local_state/home/${userName}" = {
          directories = [".cache/mozilla"];
        };
      }
    #nixos
    else {};
}
