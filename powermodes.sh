#!/bin/bash

# This script is made to easily switch between performance and power economy modes with the terminal.
# REQUIRES CPUFREQ TO WORK 

# Other recommended packages: 

# powertop (to monitor current battery drain, cpu frequencies)
# TLP (another battery economy package)

## Functions
init() {
    # Defines used colors
    YELLOW='\033[0;33m'
    NC='\033[0m'    

    # Disables pstate driver to enable other governors
    if [ /sys/devices/cpu/intel_pstate/status != "passive" ]; then  
        sudo bash -c 'echo "passive" > /sys/devices/system/cpu/intel_pstate/status' 
    fi

    # Finds the number of Threads
    THREADCOUNT=($( echo /sys/devices/system/cpu/cpu[0-99] )) 
    THREADCOUNT="${#THREADCOUNT[@]}"
    printf "Threads located: $THREADCOUNT\n"    
}

menustart() {
    clear
        printf "|-----------------------------$CURRMENU------------------------------------|\n"
}

main() {
    # If no parameters are supplied, ask for them
    if [ $# = 0 ]; then        
        CURRMENU="Main Menu"
        menustart 
        printf "Current power governor: ${YELLOW}$( cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor )${NC}\n\n"
        printf "Select your desired CPU usagemode\n"
        printf "${YELLOW}pwrs${NC}  - Enables power saving mode\n"
        printf "${YELLOW}perf${NC}  - Enables performance mode\n"
        printf "${YELLOW}std${NC}   - Enables gradual scaling mode\n"
        printf "${YELLOW}opt${NC}   - Opens the option menu\n"
        read powermode
    elif [ $1 = "startup" ]; then
        printf "bonk"
    else
        powermode=$1
    fi

    # Changes the input to the governor name
    case $powermode in 
        pwrs)
                powermode="powersave"
                modechange 
                ;;
        perf)
                powermode="performance"
                modechange
                ;;
        std)
                powermode="ondemand"
                modechange
                ;;   
        opt)
                options
                ;;
        *)
                printf "Incorrect input"
                ;;
    esac
}

options() {
    CURRMENU="Options"
    menustart
    printf "beans[y/n]\n"
    read lol
    main
}

modechange() {        
    # Changes the power governor to the specified value
    printf "Current selected mode:\n"$powermode"\n" 
        for i in `seq 0 $( expr $THREADCOUNT - 1 )`
        do
            printf "core $i: "
            echo $powermode > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor     
            printf "${YELLOW} $( cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor )${NC}\n"
        done 
}

### Main code
init
main

exit 0 # Signal sucessful execution
