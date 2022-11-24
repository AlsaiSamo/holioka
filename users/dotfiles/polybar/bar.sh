#!/usr/bin/env bash

currentBarName=/tmp/polybar.bar
defaultBar=default
secondBar=default
currentBar=$defaultBar

if [ ! -f "$currentBarName" ]; then
	echo "$currentBarName doesn't exist, creating..."
	touch $currentBarName
	echo $defaultBar > $currentBarName
	echo "Bar: $defaultBar"
else
	echo "$currentBarName exists, changing bar..."
	if [ "$defaultBar" == "$(cat $currentBarName)" ] ;then
		echo $secondBar > $currentBarName
		echo "Bar: $secondBar"
	else
		echo $defaultBar > $currentBarName
		echo "Bar: $defaultBar"
	fi
fi

currentBar=$(cat $currentBarName)

killall -q polybar
killall -q xembedsniproxy
echo "---" | tee -a /tmp/polybar-$currentBar.log
polybar $currentBar 2>&1 | tee -a /tmp/polybar-$currentBar.log & disown
echo "Bar $currentBar started"
