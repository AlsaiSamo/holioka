{lib, pkgs, ...}:

#TODO move away Atuin's key

{
	home.packages = with pkgs; [
		htop
		less
		ripgrep
		bottom
#		ncdu
#^^^^ illegal hardware instruction
		tree
		vifm
	];

	home.persistence."/state/home/imikoy" = {
		directories = [
			".local/share/zoxide"
		];
        files = [
            ".config/htop/htoprc"
        ];
	};

	programs = {
		atuin = {
			enable = true;
			enableZshIntegration = true;
			settings = {
				auto_sync = false;
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
			historyLimit=20000;
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
			options = [];
		};
        starship = {
                enable = true;
                enableZshIntegration = true;
                settings = {
#TODO do I really need to specify versions of c, cmake, Rust, and other things? They could be obtained from Nix environment
#TODO configure things - symbols shown by $status and $git_status, etc.
                        format = lib.concatStrings [
                        "$directory$nix_shell$docker_context$c$cmake$python$rust"
                        "$git_state$git_branch$git_commit$git_status"
                        "$fill"
                        "$sudo"
                        "$fill"
                        "$username$hostname"
                        "$status$cmd_duration "
                        "$line_break"
                        "$character"
                        ];
                        sudo.disabled = false;
                        status.disabled = false;
                        fill = {
                        symbol = "∙";
                        style = "238";
                            };
                };
        };

		fzf = {
			enable = true;
#enableZshIntegration = true;
#tmux.enableShellIntegration = true;
		};

		bat = {
			enable = true;
		};

		bottom = {
			enable = true;
		};

		direnv = {
			enable = true;
			nix-direnv.enable = true;
		};
        
        navi = {
            enable = true;
            enableZshIntegration = true;
        };

        noti = {
            enable = true;
        };

		exa = {
			enable = true;
		};
	};
}
