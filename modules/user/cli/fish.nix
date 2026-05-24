{
  config,
  lib,
  pkgs,
  secrets,
  userName,
  ...
}:
let
  #NOTE: run 'sudo nix-channel --update' once to get rid of "DBI connect..."
  #TODO: I do not use fish right now. The following is the todo list:
  #1. have autocompletion for nix-shell -p (list of attributes of pkgs from nixpkgs)
  #2. have insert-and-complete (re-cal lcompletion after insert)
  #3. fzf for sorting autocompletions and search (but don't change anything else)
  #4. find a list of variables used to configure fish (impossible)
  #5. replacement for !$
  #6. Make starship multiline/continuation prompt show up
  cfg = config._hlk_auto.cli;
in
{
  config = lib.mkIf (cfg.shell == "fish") {
    home.packages = with pkgs; [
      which
      fd
    ];
    programs.fish = {
      enable = true;
      package = pkgs.fish_patched;
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
      shellAbbrs = {
        gs = "git status";
        gc = "git commit";
        ga = "git add";
        gd = "git diff";
        py = "python";
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
  };
}
