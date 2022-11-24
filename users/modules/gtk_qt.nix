{lib, pkgs, ...}:

{
	home.packages = [pkgs.dconf];
	gtk = {
		enable = true;
		font = {
			name = "Ubuntu";
			size = 10;
		};
		iconTheme = {
			package = pkgs.papirus-icon-theme;
			name = "Papirus-Dark";
		};
		theme = {
			package = pkgs.breeze-gtk;
			name = "Breeze-Dark";
		};
	};
    qt = {
        enable = true;
        style.package = pkgs.libsForQt5.breeze-gtk;
#TODO theming
    };
}
