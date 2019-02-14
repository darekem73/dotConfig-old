nitrogen --restore &
conky -d -c ~/.conkyrc-stat
nm-applet &
blueman-applet &
pamac-tray &
system-config-printer-applet &
volumeicon &
xfce4-power-manager &
unclutter -idle 1 -root &
mopidy &
compton &
setxkbmap -option caps:escape
slstatus &
#synclient TapButton2=3 TapButton3=2
xautolock -time 10 -locker screenlock
