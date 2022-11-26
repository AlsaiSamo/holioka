{lib, pkgs, ...}:
let

secrets = import ../../secrets.nix;

in
{
    home.packages = with pkgs;[
        git-crypt
    ];
	programs = {
#gh =
		lazygit = {
			enable = true;
		};
		git = {
			enable = true;
			delta.enable = true;
            package = pkgs.gitFull;
            #signing = {};
            #TODO

            userEmail = secrets.gitUserEmail;
            userName  = secrets.gitUserName;
            signing.key = "3C02 CDA2 EBF0 C5AF FFC2  1B56 B5C3 DF17 6EED 79E4";
            signing.signByDefault = true;

            #TODO additional configuration options

#aliases
#TODO finish
#or use Magit
		};
	};
}
