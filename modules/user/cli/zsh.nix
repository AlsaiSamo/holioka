{
  config,
  lib,
  pkgs,
  secrets,
  userName,
  ...
}: let
  cfg = config._hlk_auto.cli;
in {
  config = lib.mkIf (cfg.shell == "zsh") {
    #Usual ZSH config
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      autocd = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      dotDir = "./.config/zsh";
      shellAliases = {
        l = "exa -halT -L 1";
        v = "$EDITOR";
        sl = "ls";
        ll = "exa -halT";
        q = "exit";
        ":q" = "exit";

        nsh = "nix-shell -p";
        gs = "git status";
        gc = "git commit";
        #TODO: add to fish
        ga = "git add";
        gd = "git diff";
      };
      #TODO: is this needed?
      loginExtra = ''
        GPG_TTY=$(tty)
        export GPG_TTY
      '';
      history = {
        ignoreSpace = true;
        save = 10000;
        share = true;
      };
      plugins = [
        {
          name = "zsh-fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
      ];
      completionInit = "autoload -U compinit && compinit ";
      initExtra = ''
        set -o vi
         zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
         unsetopt cdablevars '';
      localVariables = {EDITOR = "nvim";};
    };
    programs = {
      atuin.enableZshIntegration = true;
      zoxide.enableZshIntegration = true;
      starship.enableZshIntegration = true;
      eza.enableZshIntegration = true;
      direnv.enableZshIntegration = true;
      nix-index.enableZshIntegration = true;
    };
    home.persistence."/state/home/${userName}" = {
      allowOther = true;
      # files = [".zcompdump"];
    };
  };
}
