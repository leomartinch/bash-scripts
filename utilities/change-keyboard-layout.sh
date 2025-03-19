#!/bin/bash

# Script to toggle between keyboard layouts
# Leo Martin (2025)

### DEFINE LAYOUTS ###
layouts=(us ch de)


### SCRIPT ###
current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

index=-1 # find array index of current layout
for i in "${!layouts[@]}"; do
    if [ "${layouts[$i]}" = "$current_layout" ]; then
        index=$i
        break
    fi
done

if [ $index -eq -1 ]; then # if layout not in array, set to first layout
    new_layout=${layouts[0]}
else
    next_index=$(( (index + 1) % ${#layouts[@]} )) # get next index, wrap if at end of array
    new_layout=${layouts[$next_index]}
fi

setxkbmap -layout "$new_layout"
notify-send "keyboard set: [$new_layout]"

