#!/bin/bash

# This script implements M300 (Beep)
# Place it either in 
# Command JSON can be found in $1
# e.g. {"action":"shell_exec","params":{"M":"1338","P":"77","S":"1"}} for "M1338 P77 S1"
# Default Beep is 2500 HZ with:
# 400000 > /sys/class/pwm/pwmchip0/pwm0/period
# 200000 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
# (c) github.com/xsrf

duration=$(echo "$1" | jq -r '.params?.P?|strings')
duration=${duration:-500}
usduration=$((duration * 1000))

freq=$(echo "$1" | jq -r '.params?.S?|strings')
freq=${freq:-1000}

period=$((1000000000 / $freq))
duty_cycle=$(($period / 2))

#echo "DEBUG duration: ${duration}ms; fequency: ${freq}Hz; period: $period"

# Setup pwm0; write period twice as it may fail first if period is lower than duty_cycle
echo $period > /sys/class/pwm/pwmchip0/pwm0/period
echo $duty_cycle > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
echo $period > /sys/class/pwm/pwmchip0/pwm0/period
# enable beeper
echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
# sleep
usleep $usduration
# disbale beeper
echo 0 > /sys/class/pwm/pwmchip0/pwm0/enable
# reset pwm0 to default values
echo 400000 > /sys/class/pwm/pwmchip0/pwm0/period
echo 200000 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
echo 400000 > /sys/class/pwm/pwmchip0/pwm0/period

