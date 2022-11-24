{lib, pkgs, ...}:

{
	fonts.fonts = with pkgs; [
		(nerdfonts.override {fonts = ["FiraCode" "Iosevka" "Hack"];})
		mplus-outline-fonts.githubRelease
		noto-fonts-emoji
		ipafont
        noto-fonts
        dejavu_fonts
        roboto
        ubuntu_font_family
	];
}
