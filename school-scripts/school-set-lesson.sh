#!/bin/bash

# Function to overwrite current lesson
# Leo Martin (2025)

source "$HOME/.scripts/get-school-lesson.sh"
source "$HOME/.scripts/config.sh"
source "$HOME/.scripts/functions.sh"


### SCRIPT ###
[ -s "$set_lesson_log_file" ] && { # if set_lesson log file is not empty
    lesson_name="$(cat "$set_lesson_log_file")"
    declare -n ref_array="$lesson_name"
    lesson_array=("${ref_array[@]}")
} || { # if set_lesson log file is empty
    get_current_lesson
}


# sorts the subfolders by when they were last used
available_subfolders=$(ls -dt "$main_base_dir"/*/ 2>/dev/null)
[ -n "$available_subfolders" ] && {
    available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename)
}

lesson="$(echo -e "reset\n$available_subfolders\nprojects" | dmenu -c -bw 2 -l 20 -i -p "Set current Lesson:")"

# Cancel the script if pressed esc
[ -z "$lesson" ] && {
    exit
}

[ "$lesson" == "reset" ] && {
	> "$set_lesson_log_file" 
	notify-send -t 3000 "Lesson set to default"	
} || {
    lesson="${lesson//-/_}" # a fix for physik praktikum, need to change whole bash script
	echo "$lesson" > "$set_lesson_log_file"
	notify-send -t 3000 "Lesson changed to [$lesson]" 
}









