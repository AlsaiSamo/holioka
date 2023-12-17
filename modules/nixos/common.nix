{ config, lib, pkgs, secrets, ... }@inputs: {

  #block the most hideous ADHD distraction
  networking.hosts."127.0.0.1" = ["youtube.com" "https://www.youtube.com" "www.youtube.com"];

  security.pam.loginLimits = [
    {
      domain = "imikoy";
      type = "hard";
      item = "nofile";
      value = "65535";
    }
    {
      domain = "imikoy";
      type = "soft";
      item = "nofile";
      value = "8191";
    }
    {
      domain = "@audio";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "95";
    }
  ];

  services.udisks2.enable = true;
  programs.fuse.userAllowOther = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };
  #BUG: systemd units using bash -l -c run this. However, "not a tty" is exported.
  # environment.shellInit = ''
  #     GPG_TTY=$(tty)
  #     export GPG_TTY
  # '';
  services.kmscon = {
    enable = true;
    autologinUser = "imikoy";
    extraOptions = "";
    extraConfig = "font-size=10";
    fonts = [{
      name = "Iosevka";
      package = pkgs.iosevka;
    }];
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales =
      [ "en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];
  };
  users.users.root.hashedPassword = secrets.common.rootHashedPassword;
  environment.systemPackages = with pkgs; [
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
  ];
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
      dates = "weekly";
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise = {
      dates = [ "weekly" ];
      automatic = true;
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@wheel" ];
    };
  };
}
