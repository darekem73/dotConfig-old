#!/bin/sh
# shell script to prepend i3status with more stuff

i3status | while :
do
	read line
	echo "i3stat\t$line" || exit 1
done
