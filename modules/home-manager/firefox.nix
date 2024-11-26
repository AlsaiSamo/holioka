{
  config,
  lib,
  pkgs,
  userName,
  ...
} @ inputs: let
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
      policies = {
        # DefaultDownloadDirectory = "\${home}/Downloads";
      };
      profiles."alsaisamo" = {
        search.default = "DuckDuckGo";
        extensions = with config.nur.repos.rycee.firefox-addons; [
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
  };
}
