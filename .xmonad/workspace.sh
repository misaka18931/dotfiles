#!/bin/bash
xdotool key super+1
chrome calendar.google.com
alacritty -e "todo" &
xdotool key super+2
code &
chrome codeforces.com &
gnome-calculator &

