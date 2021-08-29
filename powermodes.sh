#!/bin/sh

# This script is made to easily switch between performance and power economy modes with the terminal.
# REQUIRES CPUFREQ TO WORK 

# Other recommended packages: 

# powertop (to monitor current battery drain, cpu frequencies)
# TLP (another battery economy package)

## Functions
init() {
    # General variables
    arg1=$1
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    cfgpath="$script_dir/config.cfg"
    govs=($( cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ))
    norepeat=1

    # Defines used colors
    yellow='\033[1;33m'
    no_colour='\033[0m'    
    green='\033[1;32m'
    red='\033[1;31m'

    # Disables pstate driver to enable other governors
    if [ /sys/devices/cpu/intel_pstate/status != "passive" ]; then  
        sudo bash -c 'echo "passive" > /sys/devices/system/cpu/intel_pstate/status' 
    fi

    # Finds the number of Threads
    threadcount=($( echo /sys/devices/system/cpu/cpu[0-99] )) 
    threadcount="${#threadcount[@]}"
    
    # Reads/creates the config file and launches the main program
    fileread  
    main
}

fileread() {    
    # Sets the option configs, creates the file if not present
    if [ -f $cfgpath ]; then
        local line=$( head -n 1 $cfgpath )
        default_governor=$line
        local line=$( head -n 2 $cfgpath | tail -n +2 )
        enable_startup=$line
        local line=$( head -n 3 $cfgpath | tail -n +3 )
        governor_selection_mode=$line
    else
            touch config.cfg
            default_governor="powersave"
            enable_startup="ON"
            governor_selection_mode="SIMPLIFIED"
            filewrite
    fi
}

filewrite() {
    # Writes/updates the config file
    echo $default_governor > $cfgpath
    echo $enable_startup >> $cfgpath
    echo $governor_selection_mode >> $cfgpath
}

menustart() {
    # Just for the menu bar
    clear
    printf "|-----------------------------$current_menu------------------------------------|\n"
}

main() {
    # If no parameters are supplied, ask for them
    if [ "$arg1" = "" ]; then        
        current_menu="Main Menu"
        menustart
        printf "Current power governor: ${yellow}$( cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor )${no_colour}\n"
        printf "Select your desired CPU power governor\n"
        if [ "$governor_selection_mode" = "SIMPLIFIED" ]; then
            printf "${yellow}pwrs${no_colour}  - Enables power saving mode\n"
            printf "${yellow}perf${no_colour}  - Enables performance mode\n"
            printf "${yellow}std${no_colour}   - Enables gradual scaling mode\n"
        else
            for i in "${govs[@]}"; do
                printf "${yellow}$i${no_colour}\n"
            done
        fi
        printf "${yellow}opt${no_colour}   - Opens the option menu\n"
        printf "${yellow}ext${no_colour}   - Exits the script\n"
        read powermode
    else
        powermode=$arg1
    fi

    # Changes the input to the governor name
    if [ "$governor_selection_mode" = "SIMPLIFIED" ]; then
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
            ext)
                    exit 0
                    ;;
            startup)
                    if [ $enable_startup = "ON" ]; then
                        powermode="$default_governor"
                        modechange
                    fi
                    ;;
            *)
                    printf "Incorrect input"
                    main
                    ;;
        esac
    else
        if [ $powermode = "startup" ]; then
            if [ $enable_startup = "ON" ]; then
                powermode="$default_governor"
                modechange
            fi
        fi
        if [ "$powermode" = "opt" ]; then
            options
        elif [ "$powermode" = "ext" ]; then
            exit 0
        elif [ "$governor_selection_mode" = "EXTENDED" ]; then
            local loopnum=1            
            for i in "${govs[@]}"; do
                if [ "$i" = "$powermode" ]; then
                    break
                elif [ $loopnum = ${#govs[@]} ]; then
                    printf "Wrong selection!"
                    sleep 1
                    printf "NOREPEAT "
                    main
                fi
                loopnum=$( expr $loopnum + 1 )
            done  
            if [ $norepeat = 1 ]; then
                modechange
                norepeat=0
            fi            
        fi
    fi
}

modechange() {        
    # Changes the power governor to the specified value
        for i in `seq 0 $( expr $threadcount - 1 )`
        do
            printf "Thread $i: "
            echo $powermode > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor     
            printf "${yellow}$( cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor )${no_colour}\n"
        done 
}

options() {
    # Launches the option screens
    current_menu="Options"    
    menustart
    printf "Default power governor [${yellow}$default_governor${no_colour}]\n" 
    printf "Set governor on startup ["
    if [ "$enable_startup" = "ON" ]; then
        printf "${green}$enable_startup${no_colour}]\n"
    else
        printf "${red}$enable_startup${no_colour}]\n"
    fi
    printf "Governor selection: [${yellow}$governor_selection_mode${no_colour}]\n"
    printf "Threads located: [${yellow}$threadcount${no_colour}]\n"    
    printf "\n"
    printf "Change Power governor [G]\n"
    printf "Change on startup [S]\n"
    printf "Go back [B]\n"
    printf "Enable/Disable simple selection menu [M]\n"    
    read userinput

    # Handles the option changing
    case $userinput in
        [Gg])                     
                printf "Avaiable governors:\n"
                for i in "${govs[@]}"; do
                    printf "${yellow} $i ${no_colour}\n"
                done
                printf "Input new default governor\n"
                read userinput
                for i in "${govs[@]}"; do
                    if [ $userinput = $i ]; then
                        default_governor="$userinput"
                        filewrite
                    fi
                done
                options
                ;;
        [Ss])
                if [ "$enable_startup" = "ON" ]; then
                    enable_startup="OFF"
                else
                    enable_startup="ON"
                fi
                filewrite
                options
                ;;        
        [Bb])
                main
                ;;
        [Mm])    
                if [ $governor_selection_mode = "SIMPLIFIED" ]; then
                    governor_selection_mode="EXTENDED"
                else
                    governor_selection_mode="SIMPLIFIED"
                fi
                filewrite
                options
                ;;
        *)
                printf "Wrong input"
                options
                ;;
    esac
}

### Main code

init $1

exit 0 # Signal sucessful execution
