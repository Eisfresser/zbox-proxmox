# switch to x.org instead of wayland by setting WaylandEnable=false in /etc/gdm3/custom.conf
OUTPUT=XWAYLAND0
OUTPUT=HDMI-3
# get modeline with cvt 1920 1200 50
xrandr --newmode "1920x1200_50.00"  158.25  1920 2040 2240 2560  1200 1203 1209 1238 -hsync +vsync
xrandr --addmode $OUTPUT "1920x1200_50.00"
xrandr --output $OUTPUT --mode "1920x1200_50.00"
sleep 1
