{ config, pkgs, ... }:

#TODO these are packages common to every host
{
	environment.systemPackages = with pkgs; [
		htop
		coreutils-full
		git
		ntfs3g
		openssl
		traceroute
		vim
		wget
	];
}
