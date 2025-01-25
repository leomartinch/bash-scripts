#!/bin/bash

source "/home/leomartin/.scripts/get-school-lesson.sh"

download_dir="/home/leomartin/downloads"
set_lesson_log_file="/home/leomartin/.scripts/.set_lesson.log"


### FUNCTIONS ###
function get_last_dir {
	last_visited_dir=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
	echo "$last_visited_dir"
}

function write_last_dir {
	dir_variable_name="${lesson_array[2]}"
	grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s|^$dir_variable_name=.*|$dir_variable_name=$1|" "$last_visited_dir_file" 
}




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


file="$(ls -t1 "$download_dir" | dmenu -c -l 5 -i -p  "Choose File to move: ")"

# Cancel the script if pressed esc
[ -z "$file" ] && {
    exit
}

# if spaces in filename change to '-'
new_filename="$(echo "" | dmenu -c -l 1 -i -p "Rename [$file]: " <&- | sed 's/ /\-/g')"

[ -z "$new_filename" ] && {
	exit
}

# sorts the subfolders by when they were last used
available_subfolders=$(ls -dt "${lesson_array[0]}"/*/ 2>/dev/null)
[ -n "$available_subfolders" ] && {
    available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename)
}
folder=$(echo -e "$available_subfolders" | dmenu -c -l 5 -i -p "Choose Folder: ")
[ -d "${lesson_array[0]}/$folder" ] || {
    mkdir "${lesson_array[0]}/$folder"
    notify-send -t 5000 "Folder $folder/ created"
}

original_filename=$(basename -- "$file")
main_extension="${original_filename##*.}"

# if the file is .docx then it converts it to .odt and deletes the old one
#[ "$main_extension" == "docx" ] && {
#	libreoffice --headless --convert-to odt "$download_dir/$file" --outdir "$download_dir" && rm "$download_dir/$file" 
#	notify-send -t 5000 ".docx File was succesfully converted to .odt"
#	file=(echo $original_filename | sed 's/\.docx/.odt/')
#	filename_with_extension="$new_filename.odt"
#}

filename_with_extension="$new_filename.$main_extension"

# Move file, update timestamp and then notify user
mv "$download_dir/$file" "${lesson_array[0]}/$folder/$filename_with_extension" && touch "${lesson_array[0]}/$folder/$filename_with_extension" && notify-send -t 3000 "File moved" 






