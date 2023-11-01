#!/bin/bash

if [ ! -f /userdata/system/lcd_backlight ]; then
  touch /userdata/system/lcd_backlight
  echo 000000 > /userdata/system/lcd_backlight
fi

VALUE=$(cat /userdata/system/lcd_backlight)
if [ $VALUE -ge 000000 ]; then
	echo $((VALUE-1000000)) > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
	echo $((VALUE-1000000)) > /userdata/system/lcd_backlight
	sync
fi

