# set screen refresh rate to 50 Hz for old Samsung display on mac maini

xrandr --newmode "1920x1200_58.00"  185.50  1920 2048 2248 2576  1200 1203 1209 1243 -hsync +vsync
xrandr --addmode HDMI-3 "1920x1200_50.00"
xrandr --output HDMI-3 --mode "1920x1200_50.00"
pause
