#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
killall -q xembedsniproxy
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar default 2>&1 | tee -a /tmp/polybar1.log & disown

if [ $(polybar -m | cut -d":" -f1 | tail -n +2) = 'HDMI-1-0' ]; then
	polybar extra 2>&1 | tee -a /tmp/polybar2.log & disown
fi

echo "Bars launched..."
