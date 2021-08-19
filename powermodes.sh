#!/bin/sh

# This script is made to easily switch between performance and power economy modes with the terminal.
# !!!! REQUIRES CPUFREQ TO WORK !!!!

# Other recommended packages: 
# powertop (to monitor current battery drain, cpu frequencies)
# TLP (another battery economy package)
###

clear
sudo bash -c 'echo "passive" > /sys/devices/system/cpu/intel_pstate/status'
if [ $# = 0 ]; then # If no parameters are supplied, ask for them
    echo ""
    echo "Current power governor: $( cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor )"
    echo "Select your desired CPU usagemode"
    echo ""
    echo "pwrs  - Triggers power saving mode"
    echo "perf  - Triggers performance mode"
    echo "std   - Triggers gradual scaling mode"
    read powermode  
    echo ""
else
    powermode=$1
fi

case $powermode in
    pwrs)
            echo "Changing to power saving mode..."
            for i in 0 1 2 3 4 5 6 7
            do
                echo "core $i: "
                echo powersave > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor     # Sets the new scaling governor
                cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor  # Prints the new scaling governor, easier to track if code failed              
            done   
            ;;
    perf)
            echo "Changing to performance mode..."
            for i in 0 1 2 3 4 5 6 7
            do
                echo "core $i: "
                echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor     # Sets the new scaling governor
                cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor  # Prints the new scaling governor, easier to track if code failed
            done 
            ;;
    std)
            echo "Changing to gradual scaling mode..."
            for i in 0 1 2 3 4 5 6 7
            do
                echo "core $i: "
                echo ondemand > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor     # Sets the new scaling governor
                cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor  # Prints the new scaling governor, easier to track if code failed
            done 
            ;;   
    *)
            echo "wrong input"
            ;;
esac
