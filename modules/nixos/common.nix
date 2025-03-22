{
  config,
  lib,
  pkgs,
  secrets,
  ...
} @ inputs: {
  options.hlk.common.enable = lib.mkEnableOption "common stuff that is usually enabled";
  config = lib.mkIf config.hlk.common.enable {
    time.timeZone = lib.mkDefault secrets.common.timeZone;

    system.tools.nixos-option.enable = false;

    hardware.enableRedistributableFirmware = true;

    services.udisks2.enable = true;
    programs.fuse.userAllowOther = true;

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    services.kmscon = {
      enable = true;
      extraConfig = "font-size=10";
      fonts = [
        {
          name = "Iosevka";
          package = pkgs.iosevka;
        }
      ];
    };
    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = ["en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8"];
      extraLocaleSettings = {LC_TIME = "ru_RU.UTF-8";};
    };

    hardware.bluetooth.enable = true;

    users.users.root.hashedPassword = secrets.common.rootHashedPassword;
    environment.systemPackages = with pkgs; [
      jq
      gvfs
      sqlite
      p7zip
      htop
      pinentry
      gnupg
      git-crypt
      gitFull
      tree
      tmux
      ripgrep
      iproute2
      jq
      ntfs3g
      udiskie
      libsecret
      libnotify
    ];
    #TODO: leave this here or replace?
    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        q = "exit";
        ":q" = "exit";
        v = "nvim";
        "vim" = "nvim";
      };
    };
    nix = {
      gc = {
        dates = "monthly";
        automatic = true;
        options = "--delete-older-than 30d";
      };
      optimise = {
        dates = ["weekly"];
        automatic = true;
      };
      settings = {
        experimental-features = ["nix-command" "flakes"];
        trusted-users = ["@wheel"];
      };
    };
  };
}
