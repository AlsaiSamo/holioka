{lib, pkgs, ...}:
{
	home.packages = with pkgs; [
		rofi-power-menu
		rofi-mpd
	];
	home.persistence."/state/home/imikoy".files = [".cache/rofi3.druncache"];
	programs.rofi = {
		enable = true;
		cycle = true;
		location = "center";
		theme = "gruvbox-dark-soft";
		plugins = with pkgs; [
			rofi-power-menu
			rofi-mpd
#TODO make scratchpad work
#would need to understand how to work with scripts
		];
		extraConfig = {
			width = 50;
			lines = 20;
			columns = 1;
			show-icons = true;
		};
	};
}
