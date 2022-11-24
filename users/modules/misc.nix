{lib, pkgs, ...}:

{	
	programs = {
		taskwarrior = {
			#enable = true;
			colorTheme = "dark-256";
#			extraConfig = 
	       };
	};
	services.kdeconnect.enable = true;
	services.kdeconnect.indicator = true;
}
