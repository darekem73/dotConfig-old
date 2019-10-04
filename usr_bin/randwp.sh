#!/bin/bash

while true; do 
	feh --bg-fill `du -a /usr/share/backgrounds/ | egrep ".jp[e]*g|.png" | awk '{ print $2 }' | shuf | head -1`
	sleep 600
done
