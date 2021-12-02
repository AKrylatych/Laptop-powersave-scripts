#!/bin/bash

clear
sensors > sensors.txt
input=$(cat sensors.txt)
picked=( $(grep -B 1  Adapter sensors.txt) )
linecount=( $(wc -l sensors.txt) )
printf "${linecount[0]}"
for i in $(seq 0 $linecount); do

    printf "line $i :    ${picked[i]}\n"
done

sleep 6s