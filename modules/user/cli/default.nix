select_user:
{
  config,
  lib,
  pkgs,
  userName,
  secrets,
  ...
}@inputs:
let
  cfg = config._hlk_auto.cli;
  options._hlk_auto.cli = {
    core.enable = lib.mkEnableOption "core CLI programs";
    extra.enable = lib.mkEnableOption "additional CLI programs";
    shell = lib.mkOption {
      example = "fish";
      description = "What shell the user will have.";
      default = "zsh";
      type = lib.types.enum [
        "zsh"
        "fish"
      ];
    };
    starship.enable = lib.mkOption {
      example = true;
      description = "starship prompt";
      default = false;
      type = lib.types.bool;
    };
  };
  reset_usb = pkgs.writeScriptBin "reset_usb.sh" ''
    #!/usr/bin/env bash
    # Resets all USB host controllers of the system.
    # This is useful in case one stopped working
    # due to a faulty device having been connected to it.

        base="/sys/bus/pci/drivers"
        sleep_secs="1"

    # This might find a sub-set of these:
    # * 'ohci_hcd' - USB 3.0
    # * 'ehci-pci' - USB 2.0
    # * 'xhci_hcd' - USB 3.0
        echo "Looking for USB standards ..."
        for usb_std in "$base/"?hci[-_]?c*
        do
            echo "* USB standard '$usb_std' ..."
            for dev_path in "$usb_std/"*:*
            do
                dev="$(basename "$dev_path")"
                echo "  - Resetting device '$dev' ..."
                printf '%s' "$dev" | sudo tee "$usb_std/unbind" > /dev/null
                sleep "$sleep_secs"
                printf '%s' "$dev" | sudo tee "$usb_std/bind" > /dev/null
                echo "    done."
            done
            echo "  done."
        done
        echo "done."
  '';
in
{
  imports =
    if select_user then
      [
        ./zsh.nix
        ./fish.nix
        ./starship.nix
      ]
    else
      [ ];
  config =
    if
      select_user
    #hm
    then
      lib.mkMerge [
        #   #NOTE: didn't work, import the files and mkIf there instead
        #   #(lib.mkIf (cfg.shell == "zsh") (import ./zsh.nix inputs))
        (lib.mkIf cfg.core.enable {
          home.sessionVariables = {
            EDITOR = "nvim";
            #TODO: try this out
            # CARGO_BUILD_BUILD_DIR = "{cargo-cache-home}";
            # CARGO_HOME = "/local_state/home/${userName}/.cargo";
          };
          home.packages = with pkgs; [
            xxd
            ripgrep
            git-crypt
            #python3Full
            python3
          ];
          programs.delta = {
            enable = true;
            enableGitIntegration = true;
            options = {
              line-numbers = true;
              side-by-side = true;
              theme = "zenburn";
            };
          };
          programs.git = {
            enable = true;
            package = pkgs.gitFull;

            settings = {
              user.email = secrets.common.gitUserEmail;
              user.name = secrets.common.gitUserName;
              signing.key = secrets.common.gitSigningKey;
              signing.signByDefault = true;
              init.defaultBranch = "main";
              push.followTags = true;
            };
          };
          #TODO: try using gpg without this
          programs.bash.profileExtra = ''
            GPG_TTY=$(tty)
            export GPG_TTY
          '';
          programs = {
            zoxide.enable = true;
            fzf.enable = true;
            bat.enable = true;
            eza.enable = true;
            fd.enable = true;
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
          environment.systemPackages = [ reset_usb ];
          programs.bash.enable = true;
          users.users.${userName}.shell =
            if cfg.shell == "zsh" then
              pkgs.zsh
            #NOTE: there may be issues in using fish as a login shell,
            #a workaround may be needed.
            #However, I am yet to notice any issues
            else if cfg.shell == "fish" then
              pkgs.fish_patched
            else
              pkgs.bash;
          environment.persistence."/state".users.${userName} = {
            directories = [
              ".local/share/zoxide"
              ".local/share/direnv"
              ".config/htop"
            ];
          };
        })
        (lib.mkIf (cfg.shell == "fish") {
          programs.fish.enable = true;
          programs.fish.package = pkgs.fish_patched;
          environment.persistence."/state".users.${userName} = {
            directories = [ ".local/share/fish" ];
          };
        })
        (lib.mkIf (cfg.shell == "zsh") {
          programs.zsh.enable = true;
        })
      ];
  inherit options;
}
