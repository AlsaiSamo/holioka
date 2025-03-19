select_user: {
  config,
  lib,
  pkgs,
  userName,
  secrets,
  ...
} @ inputs: let
  cfg = config._hlk_auto.cli;
  options._hlk_auto.cli = {
    core.enable = lib.mkEnableOption "core CLI programs";
    extra.enable = lib.mkEnableOption "additional CLI programs";
    shell = lib.mkOption {
      example = "fish";
      description = "What shell the user will have.";
      default = "zsh";
      type = lib.types.enum ["zsh" "fish"];
    };
    starship.enable = lib.mkOption {
      example = true;
      description = "starship prompt";
      default = false;
      type = lib.types.bool;
    };
  };
in {
  imports =
    if select_user
    then [./zsh.nix ./fish.nix ./starship.nix]
    else [];
  config =
    if select_user
    #hm
    then
      lib.mkMerge [
        #   #NOTE: didn't work, import the files and mkIf there instead
        #   #(lib.mkIf (cfg.shell == "zsh") (import ./zsh.nix inputs))
        (lib.mkIf
          cfg.core.enable
          {
            home.sessionVariables = {
              #TODO: may change if helix is involved
              EDITOR = "nvim";
            };
            home.packages = with pkgs; [
              xxd
              ripgrep
              git-crypt
              python3Full
            ];
            home.persistence."/state/home/${userName}" = {
              allowOther = true;
              files = [".config/htop/htoprc"];
              directories = [".local/share/zoxide" ".local/share/direnv"];
            };

            programs.git = {
              enable = true;
              delta.enable = true;
              delta.options = {
                line-numbers = true;
                side-by-side = true;
                theme = "zenburn";
              };
              package = pkgs.gitFull;

              userEmail = secrets.common.gitUserEmail;
              userName = secrets.common.gitUserName;
              signing.key = secrets.common.gitSigningKey;
              signing.signByDefault = true;

              extraConfig = {
                init.defaultBranch = "main";
                push.followTags = true;
              };
            };
            #TODO: is this needed?
            programs.bash.profileExtra = ''
              GPG_TTY=$(tty)
              export GPG_TTY
            '';
            programs = {
              zoxide.enable = true;
              fzf.enable = true;
              bat.enable = true;
              eza.enable = true;
              direnv = {
                enable = true;
                nix-direnv.enable = true;
              };
              atuin = {
                enable = true;
                settings = {
                  auto_sync = false;
                  update_check = false;
                  dialect = "us";
                  db_path = "/state/home/${userName}/.local/share/atuin/history.db";
                  key_path = "/state/home/${userName}/.local/share/atuin/key";
                  session_path = "/state/home/${userName}/.local/share/atuin/session";
                  search_mode = "fuzzy";
                  filter_mode = "host";
                };
              };
              tmux = {
                enable = true;
                clock24 = true;
                terminal = "tmux-256color";
                historyLimit = 20000;
                escapeTime = 5;
                keyMode = "vi";
                extraConfig = ''
                  set -g set-titles on
                  set -g set-titles-string "TMUX###S: #T"
                  set-option -sa terminal-overrides ',alacritty:RGB'
                '';
                sensibleOnTop = true;
              };
            };
          })
        (lib.mkIf cfg.extra.enable {
          programs = {
            #nix-index.enable = true;
          };
          home.packages = with pkgs; [
            ncdu
            powertop
            yt-dlp
            jq
            scc
            imagemagick
            hexyl
          ];
        })
      ]
    #nixos
    else
      lib.mkMerge [
        (lib.mkIf cfg.core.enable {
          users.users.${userName}.shell =
            if cfg.shell == "zsh"
            then pkgs.zsh
            #NOTE: there may be issues in using fish as a login shell,
            #a workaround may be needed.
            #However, I am yet to notice any issues
            else if cfg.shell == "fish"
            then pkgs.fish
            else pkgs.bash;
        })
        (lib.mkIf (cfg.shell == "fish") {
          programs.fish.enable = true;
        })
      ];
  inherit options;
}
