{lib, pkgs, config, ...}:
{
	services = {
		mpd = {
			enable = true;
			dataDir = /state/home/imikoy/.local/mpd;
	    	musicDirectory = /home/imikoy/Music;
		};
	};
	programs.ncmpcpp = {
		enable = true;
	};
}
