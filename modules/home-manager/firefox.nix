{
  config,
  lib,
  pkgs,
  userName,
  ...
} @ inputs:
#TODO: look into profiles and using them to install extensions.
let
  cfg = config.hlk.firefox;
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
  };
in {
  options.hlk.firefox = {
    default.enable = lib.mkEnableOption "default Firefox configuration";
  };
  config = lib.mkIf cfg.default.enable {
    programs.firefox = {
      enable = true;
      package = myFirefox;
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
  };
}
