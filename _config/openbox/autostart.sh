#! /bin/bash

sparky-polkit &
nitrogen --restore && \
if [ -f /usr/bin/tint2 ]; then
	tint2 &
elif [ -f /usr/bin/fbpanel ]; then
	fbpanel &
fi
xscreensaver -nosplash &
(sleep 5; pnmixer) &
thunar --daemon &
if [ -f /opt/sparky/nm-applet-reload ]; then
	/opt/sparky/nm-applet-reload &
fi
if [ -f /usr/bin/xfce4-power-manager ]; then
	/usr/bin/xfce4-power-manager &
fi
setxkbmap -option caps:escape
compton -b
conky -d -c ~/.conkyrc-stat
mopidy &

