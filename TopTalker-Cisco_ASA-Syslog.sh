#!/bin/bash

INGRESS_INTERFACE="OUTSIDE"
EGRESS_INTERFACE="INTERNAL"
 cat $1 | \
   grep bytes |egrep "Teardown UDP state-bypass|Teardown TCP state-bypass"  |  \
   cut -d ' ' -f16,18,23 | \
   awk '{gsub("${INGRESS_INTERFACE}:", "");print}'  | \
   awk '{gsub("${EGRESS_INTERFACE}:", "");print}'  | \
   awk '{gsub("/", " ");print}'   | \
   cut -d ' ' -f1,3,5  | \
   egrep -v " 0" | \
   perl -lane '$k{"$F[0] $F[1]"}+=$F[2]+$F[3];
           END{print "$_ $k{$_}" for keys(%k) }'  | \
   sort -k3 -n | \
   tail -n 200
