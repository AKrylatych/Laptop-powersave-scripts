# Laptop-powersave-scripts
This is a script made to improve battery life on linux laptops. </br>
It allows to switch between cpu power usage modes in the bash terminal.

# Usage
Execute the script with superuser privileges (it's required to unlock more power governors and for switching between cpu usage modes) </br>
Type the name of the mode you wish to choose and hit enter. </br>
In the options menu you can switch to an extended mode that shows even more cpu power usage modes. </br>

Basic modes include:    
Performance mode - Sets the CPU clock speeds to max, regardless of the load </br>
Power saving mode - Sets the CPU clock speeds to minimum, regardless of the load </br>
Gradual scaling (ondemand) - Sets the CPU clock speeds depending on the load. </br>

You can also input your desired mode as a parameter when executing the script to bypass the GUI entirely.   </br>

# Required packages
Cpufreq-utils
    
![Screenshot](head/scr1.png)
![Screenshot](head/scr2.png)
![Screenshot](head/scr3.png)
