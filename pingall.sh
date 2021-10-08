#!/bin/bash
# Program name: pingall.sh
printf "#################################################\n"
date
printf "\n#################################################\n"
cat $1 |  while read output
do
    ping -c 1 "$output" > /dev/null
    if [ $? -eq 0 ]; then
    echo "OK OK OK node $output is up OK OK OK"
    else
    echo "NOK NOK NOK node $output is down NOK NOK NOK"
    fi
    printf "\n"
    traceroute -T -m 12 "$output"
    printf "\n#################################################\n"
#    if [ $? -eq 0 ]; then
#    echo "traceroute $output is OK"
#    else
#    echo "traceroute $output is NOK"
#    fi
done
