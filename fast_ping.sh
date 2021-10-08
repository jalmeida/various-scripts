#!/bin/bash
# Filename: fast_ping.sh
# It makes a parallel ping to full subnet and then get MAC address
# Just work with first 3 octect from /24 subnet
# Usage: ./fast_ping.sh 192.168.0




for ip in $1.{1..255}
do
   (
      ping $ip -c2 &> /dev/null ;
      if [ $? -eq 0 ];
      then
       echo $ip is alive
      fi
   )&
  done
wait

arp -na | egrep -e "${1}" | grep -v incom
