{lib, pkgs, ...}:
let
myFirefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    cfg = {
        enableTridactylNative = true;
    };
    extraPolicies = {
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        PromptForDownloadLocation = true;
#			SearchEngines.Default = 
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
#TODO addons are still not loaded automatically
#Firefox has opinions on autoloading things
    extraPrefs = ''
        defaultPref("extensions.enabledScopes", 15);
    defaultPref("extensions.autoDisableScopes", 0);
    '';
};
in
{
    home.persistence."/state/home/imikoy" = {
        files = [
            ".config/tridactyl/tridactylrc"
        ];
        directories = [
            ".mozilla/firefox"
                ".cache/mozilla"
        ];
    };
    programs.firefox = {
        enable = true;
        package = myFirefox;
#TODO add other extensions
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
                tridactyl
                firefox-color
                keepassxc-browser
        ];
    };
}
