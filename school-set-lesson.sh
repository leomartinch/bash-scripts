#!/bin/bash

source "/home/leomartin/.scripts/get-school-lesson.sh"

download_dir="/home/leomartin/downloads"
set_lesson_log_file="/home/leomartin/.scripts/.set_lesson.log"


#--FUNCTIONS--#
function get_last_dir {
	last_visited_dir=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
	echo "$last_visited_dir"
}

function write_last_dir {
	dir_variable_name="${lesson_array[2]}"
	grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s|^$dir_variable_name=.*|$dir_variable_name=$1|" "$last_visited_dir_file" 
}





#--SCRIPT--#
[ -s "$set_lesson_log_file" ] && { # if set_lesson log file is not empty
    lesson_name="$(cat "$set_lesson_log_file")"
    declare -n ref_array="$lesson_name"
    lesson_array=("${ref_array[@]}")
} || { # if set_lesson log file is empty
    get_current_lesson
}


# sorts the subfolders by when they were last used
available_subfolders=$(ls -dt "/home/leomartin/documents/school"/*/ 2>/dev/null)
[ -n "$available_subfolders" ] && {
    available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename)
}

lesson="$(echo -e "reset\n$available_subfolders" | dmenu -c -l 10 -i -p "Set current Lesson:")"

# Cancel the script if pressed esc
[ -z "$lesson" ] && {
    exit
}

[ "$lesson" == "reset" ] && {
	> "$set_lesson_log_file" 
	notify-send -t 3000 "Lesson set to default"	
} || {
	echo "$lesson" > "$set_lesson_log_file"
	notify-send -t 3000 "Lesson changed to [$lesson]" 
}









