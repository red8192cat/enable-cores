#! /bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

usage() {
  echo -e " Usage: $0 [number of cores you want to set to active; all the other cores will be disabled]
 Examples: $0 2"
}

if [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]] ; then usage; fi

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cores=$1
max_cores=$( cat /sys/devices/system/cpu/present | awk '{print substr($0,length($0),1)}' ) 
(( max_cores++ )) 

if [[ -z $cores ]] ; then echo "No cores number was provided" ; usage ; exit 1 ; fi
if [[ "$cores" -lt "1" ]] || [[ $cores -gt $max_cores ]] ; then echo "Wrong number, should be between 1 and ${max_cores}" ; exit 1 ; fi

echo -en "${GREEN}[0] ${NC}"

for (( enabled=1; enabled<$cores; enabled++ ))
  do
    echo 1 > /sys/devices/system/cpu/cpu$enabled/online
    echo -en "${GREEN}[$enabled] ${NC}"
done


for (( disabled=$cores; $disabled<$max_cores; disabled++ )) 
  do
    echo 0 > /sys/devices/system/cpu/cpu$disabled/online
    echo -en "${RED}[$disabled] ${NC}"
done

echo

#if [[ "$cores" -eq "1" ]] ; 
#  then echo "Only $cores core is enabled" ; 
#  else echo "$cores cores are enabled" ;
#fi

real_cores_active=$( cat /proc/cpuinfo | grep "processor" | awk -F ':' '{ print $2 }' | tail -n1 )

if [[ $cores -ne $real_cores_active+1 ]] ; 
  then echo "Something went wrong, check the cores manually" exit 1 ;
fi

