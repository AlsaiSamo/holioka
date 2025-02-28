{
  config,
  lib,
  pkgs,
  secrets,
  userName,
  ...
}: let
  #NOTE: run 'sudo nix-channel --update' once to get rid of "DBI connect..."
  #TODO: have autocompletion for nix-shell -p (list of attributes of pkgs from nixpkgs)
  #TODO: have insert-and-complete (re-cal lcompletion after insert)
  #TODO: fzf for sorting autocompletions and search (but don't change anything else)
  #TODO: find a list of variables used to configure fish (impossible)
  cfg = config._hlk_auto.cli;
in {
  config = lib.mkIf (cfg.shell == "fish") {
    home.persistence."/state/home/${userName}" = {
      allowOther = true;
      directories = [".local/share/fish"];
    };
    home.packages = with pkgs; [
      which
      fd
    ];
    programs.fish = {
      enable = true;
      #TODO: proper fuzzy completion (currently it is not fuzzy but close enough)
      plugins = [
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
      ];
      functions = {
        expand_history_prev = "string collect $history[1]";
      };
      shellAliases = {
        l = "exa -halT -L 1";
        sl = "ls";
        ll = "exa -halT";
        q = "exit";
        Q = "exit";
        ":q" = "exit";
      };
      #TODO: write a replacement of !$
      #and something to toggle private mode
      shellAbbrs = {
        gs = "git status";
        gc = "git commit";
        v = "$EDITOR";
        nsh = "nix-shell -p ";
        "!!" = {
          position = "anywhere";
          function = "expand_history_prev";
        };
      };
      interactiveShellInit = ''
        bind \t complete-and-search-fw
        bind -M insert \t complete-and-search-fw
        bind -M visual \t complete-and-search-fw

        set -U fish_greeting
        set -g fish_key_bindings fish_vi_key_bindings

        set -U __done_min_cmd_duration 30000 # in ms
        set -U __done_exclude '^git (?!push|pull|fetch|clone)'
        set -U --append __done_exclude '^emacsclient'
        set -U __done_notify_sound 0
        set -U __done_sway_ignore_visible 1
        set -U __done_notification_urgency_level low
        set -U __done_notification_urgency_level_failure normal
        set -U __done_notification_duration 15000 # in ms
      '';
    };
    #NOTE: here I was setting enableFishIntegration to
    #direnv, atuin, zoxide, starship, fzf, eza, nix-index and services.gpg-agent,
    #but this is not required lol (they are set to true already)
  };
}
