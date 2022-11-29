{lib, pkgs, ...}:

{
	home.packages = [pkgs.dconf];
    dconf.enable = true;
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
			package = pkgs.gnome.gnome-themes-extra;
			name = "Adwaita";
		};
        gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
        };
	};
    qt = {
        enable = true;
        style.package = pkgs.adwaita-qt;
    };
}
