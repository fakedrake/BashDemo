#!/bin/bash

# Author: Chris Perivolaropoulos 2012
# Commentary:
# Create files in this directory with the names of the locations and put them in the KEYS variable
# containing newline separated mac addresses tha are visible at that
# location.

KEYS=("ece" "home")

if [[ "$1" == "-f" ]]; then
    shift
    SCAN_COMMAND="cat $1";
else
    SCAN_COMMAND="sudo iwlist wlan0 scan"
fi;

echo "Determined command for canning: $SCAN_COMMAND"
MACS=$($SCAN_COMMAND | sed -n "s/.*Address: \([0-9A-F:]*\)$/\1/p")

home_ind=0
school_ind=0

# From a linux journal aritcle
float_scale=2

function float_eval()
{
    local stat=0
    local result=0.0
    if [[ $# -gt 0 ]]; then
        result=$(echo "scale=$float_scale; $*" | bc -q 2>/dev/null)
        stat=$?
        if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
    fi
    echo $result
    return $stat
}

function float_cond()
{
    local cond=0
    if [[ $# -gt 0 ]]; then
        cond=$(echo "$*" | bc -q 2>/dev/null)
        if [[ -z "$cond" ]]; then cond=0; fi
        if [[ "$cond" != 0  &&  "$cond" != 1 ]]; then cond=0; fi
    fi
    local stat=$((cond == 0))
    return $stat
}

function contains 
{
    local e;
    for e in "${@:2}"; # Parameter expansion, from the 2nd onwards
    do
	[[ "$e" == "$1" ]] && return 0;
    done;
    return 1;
}

declare -A place
declare -A counter

# Initialize
for i in ${KEYS[@]}; do
    counter[$i]=0
    place[$i]=$(cat $i)
done;

# Count
for MAC in $MACS; do
    for KEY in ${KEYS[@]}; do
	contains $MAC ${place[$KEY]} && ((counter[$KEY]++))
    done;
done;

# Print counting results
echo "Counters:"
for KEY in ${KEYS[@]}; do
    p=(${place[$KEY]});
    echo $KEY: ${counter[$KEY]}/${#p[@]};
done;

# Find the largest
max_ratio=0
max_key=""
for KEY in ${KEYS[@]}; do
    p=(${place[$KEY]});
    if [[ ${#p[@]} -ne 0 ]]; then
	ratio=$(float_eval "${counter[$KEY]} / ${#p[@]}");
    else
	ratio=0
    fi;
    
    if float_cond "$ratio>$max_ratio"; then
	max_ratio=$ratio;
	max_key=$KEY;
    fi;
done;

if [[ "$max_ratio" == "0" ]]; then
   echo "I do not know where we are.";
   max_key="an unknown location.";
else
    echo "MAX KEY: $max_key ($max_ratio)"
fi;

# Do something
source util/popup.sh "$max_key"
