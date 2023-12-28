{
  connfig,
  lib,
  pkgs,
  ...
} @ inputs:
#TODO: look into profiles and using them to install extensions.
let
  myFirefox = pkgs.wrapFirefox pkgs.firefox-esr-unwrapped {
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
      #DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
    };
    #TODO: I cannot use addons packaged by rycee due to missing extid.
    # nixExtensions = with pkgs.nur.repos.rycee.firefox-addons; [
    #     # keepassxc-browser
    #     # firefox-color
    #     # tridactyl
    #     ublock-origin
    #     #enhanced-h264ify
    #     # enhanced-h264ify
    # ];
  };
in {
  programs.firefox = {
    enable = true;
    package = myFirefox;
  };
  home.persistence."/state/home/imikoy" = {
    files = [".config/tridactyl/tridactylrc"];
    directories = [
      #Has the profile
      ".mozilla/firefox"
      #".cache/mozilla"
      #Keepassxc
      ".mozilla/native-messaging-hosts"
    ];
  };
  home.persistence."/local_state/home/imikoy" = {
    directories = [".cache/mozilla"];
  };
}
