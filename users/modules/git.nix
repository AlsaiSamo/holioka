{lib, pkgs, ...}:
let

secrets = import ../../secrets.nix;

in
{
    home.packages = with pkgs;[
        git-crypt
    ];
	programs = {
		git = {
			enable = true;
			delta.enable = true;
            delta.options = {
                line-numbers = true;
                side-by-side = true;
                theme = "gruvbox-dark";
            };
            package = pkgs.gitFull;

            userEmail = secrets.gitUserEmail;
            userName  = secrets.gitUserName;
            signing.key = "3C02 CDA2 EBF0 C5AF FFC2  1B56 B5C3 DF17 6EED 79E4";
            signing.signByDefault = true;

            extraConfig = {
                    core  = {
                        editor = "vim";
                        #pager = "bat";
                        };
                    init.defaultBranch = "main";
            };
            #TODO additional configuration options
		};
	};
}
