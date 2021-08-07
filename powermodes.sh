#!/bin/bash

# This script is made to easily switch between performance and power economy modes with the terminal.
# !!!! REQUIRES CPUFREQ TO WORK !!!!

# Other recommended packages: 
# powertop (to monitor current battery drain, cpu frequencies)
# TLP (another battery economy package)

###
if [ $# = 0 ]; then # If no parameters are supplied, ask for them
    echo "Select your desired mode"
    echo " "
    echo "pwrs"
    echo "perf"
    read powermode
else
    powermode=$1
fi

if [ $powermode = "pwrs" ]; then
    echo "Changing to power saving mode"
    for i in 0 1 2 3 4 5 6 7
    do
        echo "core $i: "
        echo powersave > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor     # Sets the new scaling governor
        cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor  # Prints the new scaling governor, easier to track if code failed
    done 
    elif [ $powermode = "perf" ]; then    # Same code, but for performance mode
        echo "Changing to performance mode"    
        for i in 0 1 2 3 4 5 6 7
        do
            echo "core $i: "
            echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor   
            cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor        
        done    
    else
        echo "wrong input" # If input is wrong, nothing is changed
fi
