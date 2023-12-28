{
  pkgs,
  config,
  lib,
  secrets,
  ...
} @ inputs: {
  home.packages = with pkgs; [ripgrep git-crypt keychain python3Full];
  home.persistence."/state/home/imikoy" = {
    allowOther = true;
    files = [".zcompdump" ".config/htop/htoprc"];
    directories = [".local/share/zoxide" ".local/share/direnv"];
  };

  programs.git = {
    enable = true;
    delta.enable = true;
    delta.options = {
      line-numbers = true;
      side-by-side = true;
      theme = "gruvbox-dark";
    };
    package = pkgs.gitFull;

    userEmail = secrets.common.gitUserEmail;
    userName = secrets.common.gitUserName;
    signing.key = secrets.common.gitSigningKey;
    signing.signByDefault = true;

    extraConfig = {
      core = {editor = "vim";};
      init.defaultBranch = "main";
      push.followTags = true;
    };
  };
  programs.bash.profileExtra = ''
    GPG_TTY=$(tty)
    export GPG_TTY
    keychain --agents ssh,gpg
  '';
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    autocd = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    dotDir = "./.config/zsh";
    shellAliases = {
      l = "exa -halT -L 1";
      v = "nvim";
      sl = "ls";
      ll = "exa -halT";
      q = "exit";
      ":q" = "exit";

      nsh = "nix-shell";
      gs = "git status";
      gc = "git commit";
    };
    loginExtra = ''
      GPG_TTY=$(tty)
      export GPG_TTY
      keychain --agents ssh,gpg
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
    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = false;
        update_check = false;
        #sync_address = ""
        #sync_frequency = ""
        dialect = "us";
        db_path = "/state/home/imikoy/.local/share/atuin/history.db";
        key_path = "/state/home/imikoy/.local/share/atuin/key";
        session_path = "/state/home/imikoy/.local/share/atuin/session";
        search_mode = "fuzzy";
        filter_mode = "host";
      };
    };

    tmux = {
      enable = true;
      clock24 = true;
      terminal = "tmux-256color";
      shortcut = "Space";
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

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = lib.concatStrings [
          #"$directory$docker_context$c$cmake$python$rust"
          "$directory$docker_context"
          #"$git_state$git_branch$git_commit$git_status"
          "$fill"
          "$sudo$nix_shell"
          "$fill"
          "$username$hostname"
          "$status"
          "$line_break"
          "$character"
        ];
        sudo.disabled = false;
        status.disabled = false;
        fill = {
          symbol = "∙";
          style = "238";
        };
        cmd_duration = {format = "⌛ [$duration]($style)";};
        directory = {
          truncation_length = 7;
          truncation_symbol = "… /";
        };
        git_status = {
          conflicted = "≠ ";
          ahead = "⇡\${count} ";
          behind = "⇣\${count} ";
          diverged = "⇅ ";
          up_to_date = "✔️ ";
          untracked = "? ";
          stashed = "🗃️ ";
          modified = "! ";
          staged = "+ ";
          renamed = "→ ";
          deleted = "⛒ ";
        };
      };
    };

    fzf = {enable = true;};

    bat.enable = true;
    exa.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
