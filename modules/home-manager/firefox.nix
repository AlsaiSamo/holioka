{ connfig, lib, pkgs, ... }@inputs:
#TODO: look into profiles and using them to install extensions.
let
  myFirefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    cfg = { enableTridactylNative = true; };
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
      #DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
    };
  };
in {
  programs.firefox = {
    enable = true;
    package = myFirefox;
    #extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    #ublock-origin
    #tridactyl
    #firefox-color
    #keepassxc-browser
    #];
  };
  home.persistence."/state/home/imikoy" = {
    files = [ ".config/tridactyl/tridactylrc" ];
    directories = [ ".mozilla/firefox" ".cache/mozilla" ".mozilla/native-messaging-hosts" ];
  };
}
