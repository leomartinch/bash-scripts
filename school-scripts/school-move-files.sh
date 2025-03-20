#!/bin/bash

# Script to move and rename files from download folder to a given school directory
# Leo Martin (2025)

source "$HOME/.scripts/get-school-lesson.sh"
source "$HOME/.scripts/config.sh"
source "$HOME/.scripts/functions.sh"


## Problems
# script does not work with files that have no extension

### SCRIPT ###

[ -s "$set_lesson_log_file" ] && { # if set_lesson log file is not empty
    lesson_name="$(cat "$set_lesson_log_file")"
    declare -n ref_array="$lesson_name"
    lesson_array=("${ref_array[@]}")
} || { # if set_lesson log file is empty
    get_current_lesson
}

file="$(ls -t1 "$download_dir" | dmenu -c -bw 2 -lbp -l 10 -i -p  "Choose File to move: ")"

# cancel the script if pressed esc
[ -z "$file" ] && exit

new_filename="$(echo "" | dmenu -c -l 1 -lbp -i -p "Rename: " <&-)"
new_filename="${new_filename// /-}" # change spaces in filename to '-'

[ -z "$new_filename" ] && exit

# sorts the subfolders by when they were last used
available_subfolders=$(ls -dt "${lesson_array[0]}"/*/ 2>/dev/null)
[ -n "$available_subfolders" ] && {
    available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename)
}

folder=$(select_folder)

original_filename=$(basename -- "$file")
main_extension="${original_filename##*.}"

filename_with_extension="$new_filename.$main_extension"

[ -e "${lesson_array[0]}/$folder/$filename_with_extension" ] && {
    is_overwrite=$(echo -e "No\nYes" | dmenu -c -p "Overwrite File?")
	[ "$is_overwrite" == "No" ] && {
		notify-send "Move Canceled"
		exit
	}
}

# move file, update timestamp and then notify user
mv -i "$download_dir/$file" "${lesson_array[0]}/$folder/$filename_with_extension" && touch "${lesson_array[0]}/
$folder/$filename_with_extension" && notify-send -t 3000 "File moved" 

### SPECIAL BEHAVIOURS ###
[ "$main_extension" == "pdf" ] && {
    exiftool -overwrite_original -Title="" "${lesson_array[0]}/$folder/$filename_with_extension"
}





