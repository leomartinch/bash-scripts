#!/bin/bash

day_of_week=$(date +%u)
current_hour=$(date +%H)
current_minute=$(date +%M)

is_between() {
    local start_hour=$1
    local start_minute=$2
    local end_hour=$3
    local end_minute=$4

    local current_total_minutes=$((10#$current_hour * 60 + 10#$current_minute))
    local start_total_minutes=$((10#$start_hour * 60 + 10#$start_minute))
    local end_total_minutes=$((10#$end_hour * 60 + 10#$end_minute))

    time_in_lesson=$(($current_total_minutes - $start_total_minutes))

    [ "$current_total_minutes" -ge "$start_total_minutes" ] && [ "$current_total_minutes" -lt "$end_total_minutes" ] && {
        return 0 # current time is between start and end
		} || {
        return 1
		}
}

is_lesson=1  # default to no lesson

get_current_lesson() {
    case $day_of_week in
        1) # Monday
		    is_between 07 45 08 30 || \
            is_between 08 40 09 25 || \
            is_between 09 35 10 20 || \
            is_between 10 35 11 20 || \
            is_between 11 30 12 15 || \
            is_between 13 20 14 05 || \
            is_between 14 15 15 00 || \
            is_between 15 10 15 55 && is_lesson=0
            ;;
        2) # Tuesday
            is_between 07 45 08 30 || \
            is_between 08 40 09 25 || \
            is_between 09 35 10 20 || \
            is_between 10 35 11 20 || \
            is_between 11 30 12 15 && is_lesson=0
            ;;
        3) # Wednesday
		    is_between 09 35 10 20 || \
		    is_between 10 35 11 20 || \
		    is_between 11 30 12 15 || \
            is_between 13 20 14 05 || \
            is_between 14 15 15 00 || \
            is_between 15 10 15 55 && is_lesson=0
            ;;
        4) # Thursday
            is_between 07 45 08 30 || \
            is_between 08 40 09 25 || \
            is_between 09 35 10 20 || \
            is_between 10 35 11 20 || \
            is_between 11 30 12 15 || \
            is_between 13 20 14 05 || \
            is_between 14 15 15 00 && is_lesson=0
            ;;
        5) # Friday
            is_between 08 40 09 25 || \
            is_between 09 35 10 20 || \
            is_between 10 35 11 20 || \
            is_between 11 30 12 15 && is_lesson=0
            ;;
        *) # Weekend
            is_lesson=1
            ;;
    esac
}


get_current_lesson

[ "$is_lesson" -eq 1 ] && {
    notify-send -t 3000 "No Lesson"
} || {    	
     seconds_left=$((60 - $(date +%S)))

	[ "$seconds_left" -eq 60 ] && {
			minutes_left=$((45 - time_in_lesson))
		    seconds_left=0
	} || {
		    minutes_left=$((44 - time_in_lesson))
	}
	
    seconds_left_formatted=$(printf "%02d" "$seconds_left")
    notify-send -t 4000 "Time Left: [$minutes_left:$seconds_left_formatted]"
}
