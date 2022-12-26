{lib, pkgs, ...}:
{
	imports = map(x: ./modules/. + x + ".nix") [
		"/firefox"
		"/git"
		"/gtk_qt"
        "/gpg"
		"/guiUtils"
		"/misc"
		"/mpd"
		"/nvim"
		"/rofi"
		"/shellUtils"
		"/x"
		"/polybar"
		"/zsh"
        "/keepass"
        "/dunst"
        "/python"
        "/kde"
	];

	home.stateVersion = "22.05";
	manual.manpages.enable = true;

	home.packages = with pkgs; [
        nheko
        xdg-utils
        xorg.xkill
        barrier
        gcc
        rustc
        cargo
        rustfmt
        nixfmt
        kicad-small
	];

	home.persistence."/state/home/imikoy" = {
		allowOther = true;
		directories = [
			"Desktop"
			"Documents"
			"Downloads"
			"Music"
			"Pictures"
            "Projects"
            ".cache/nheko"
            ".config/nheko"
            ".local/share/nheko"
		];
	};

	home.keyboard = {
		layout = "us,ru";
		options = [
            "grp:caps_toggle"
		];
	};

	home.pointerCursor = {
		name = "phinger-cursors";
		package = pkgs.phinger-cursors;
		size = 32;
	};

	i18n = {
#TODO when I'll need it
#review later
	};
	programs = {
		man = {
			enable = true;
			generateCaches = true;
		};
	};

}
