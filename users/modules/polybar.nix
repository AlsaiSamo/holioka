{pkgs, lib, ...}:

#TODO audio control
#replacing with a different script would be nice, but not required
{
	services.polybar = {
		enable = true;
		package = pkgs.polybar.override {
			i3GapsSupport = true;
			i3Support = true;
			pulseSupport = true;
			mpdSupport = true;
		};
		config = ../dotfiles/polybar/config.ini;
#script is nowhere to be found
		script = ''
			pkill polybar
			echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
			polybar default 2>&1 | tee -a /tmp/polybar1.log & disown

			echo "Bars launched..."
            exit 0
		'';
	};
}
