#!/bin/bash
# This script is made to easily switch between performance and power economy modes with the terminal.
# Creator: Hellerlight
### Main code
powermode() {
    echo "Select your desired mode"
    echo " "
    echo "pwrs"
    echo "perf"
    read powermode
    if [ $powermode = "pwrs" ]; then
        echo "Changing to power saving mode"
        for i in 0 1 2 3 4 5 6 7
        do
            echo "core $i: "
            echo powersave > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor 
            cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor       
        done 
        elif [ $powermode = "perf" ]; then    
            echo "Changing to performance mode"    
            for i in 0 1 2 3 4 5 6 7
            do
                echo "core $i: "
                echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor   
                cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor        
            done    
        else
            echo "wrong input"
    fi
}
powermode
