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
			v = "TERM=tmux nvim";
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
				name = "powerlevel10k";
				src = pkgs.zsh-powerlevel10k;
				file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
			}
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
			source $HOME/.config/zsh/.p10k.zsh
            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
		'';
		localVariables = {
			POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
            EDITOR = "nvim";
		};
	};

	xdg.configFile."zsh/.p10k.zsh".source = ../dotfiles/.p10k.zsh;
	home.persistence."/state/home/imikoy" = {
		files = [
			".zsh_history"
			".zcompdump"
		];
		directories = [
#			".config/zsh"
#^^^^ Not needed, since everything here is linked to store anyways
		];
	};
}
