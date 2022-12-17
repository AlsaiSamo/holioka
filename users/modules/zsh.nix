{lib, pkgs, ...}:
{

	programs.zsh = {
		enable = true;
		enableAutosuggestions = true;
		autocd = true;
		enableCompletion = true;
		enableSyntaxHighlighting = true;
		dotDir = "./.config/zsh";
		shellAliases = {
			l = "exa -lahT -L 1";
			sl = "ls";
			ll = "exa -lahT";
			v = "nvim";
			q = "exit";
			":q" = "exit";
#TODO tmux, nixos, and other stuffs
		};
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
        completionInit = ''
            autoload -U compinit && compinit
            #source $HOME/.config/zsh/plugins/fzf-tab.plugin.zsh
#seems to be already loaded without any issues
        '';
		initExtra = ''
			set -o vi
            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
            unsetopt cdablevars
		'';
		localVariables = {
            EDITOR = "nvim";
		};
	};

	home.persistence."/state/home/imikoy" = {
		files = [
			#".zsh_history"
#atuin preserves the history
			".zcompdump"
		];
		directories = [
#			".config/zsh"
#^^^^ Not needed, since everything here is linked to store anyways
		];
	};
}
