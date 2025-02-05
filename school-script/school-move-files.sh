#!/bin/bash

# Script to move and rename files from the downloads folder into chosen directories
# Leo Martin (2024)

source "$HOME/.scripts/get-school-lesson.sh"

download_dir="$HOME/downloads"
set_lesson_log_file="$HOME/.scripts/.set_lesson.log"


### FUNCTIONS ###
function get_last_dir {
	last_visited_dir=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
	echo "$last_visited_dir"
}

function write_last_dir {
	dir_variable_name="${lesson_array[2]}"
	grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s|^$dir_variable_name=.*|$dir_variable_name=$1|" "$last_visited_dir_file" 
}




function select_folder {
    current_dir="${lesson_array[0]}"
	available_subfolders=$(ls -dt "$current_dir"/*/ 2>/dev/null)
	local all_folder=""
		
	while : 
	do
		available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename)

		[ -z "$available_subfolders" ] && {
				local folder=$(echo -e "Create New" | dmenu -c -noi -i -p "Select Folder: ")
		} || {
				local folder=$(echo -e "$available_subfolders" | dmenu -c -l 5 -i -p "Select Folder: ")
		}

		[ -z "$folder" ] && {
				echo "$all_folder"
				exit
		}
		folder="${folder// /-}"
	
		[ "$folder" == "Create New" ] && {
				folder="$(echo "" | dmenu -c -p "Name Folder: " <&-)"
				folder="${folder// /-}"
		}

		[ -d "$current_dir/$all_folder/$folder" ] || { # create folder if does not exist already
		    mkdir "${lesson_array[0]}/$all_folder/$folder"
		    notify-send -t 5000 "Folder $folder/ created"
		}

		all_folder+="$folder/"	
		available_subfolders=$(ls -dt "$current_dir/$all_folder"*/ 2>/dev/null)
		
    done
	echo "$all_folder"

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


file="$(ls -t1 "$download_dir" | dmenu -c -bw 2 -lbp -l 10 -i -p  "Choose File to move: ")"

# Cancel the script if pressed esc
[ -z "$file" ] && exit


# if spaces in filename change to '-'
new_filename="$(echo "" | dmenu -c -l 1 -lbp -i -p "Rename: " <&-)"
new_filename="${new_filename// /-}"

[ -z "$new_filename" ] && exit


# sorts the subfolders by when they were last used
available_subfolders=$(ls -dt "${lesson_array[0]}"/*/ 2>/dev/null)
[ -n "$available_subfolders" ] && {
    available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename)
}


folder=$(select_folder)


[ -d "${lesson_array[0]}/$folder" ] || {
		folder="$(echo $folder | sed 's/ /\-/g')"
    mkdir "${lesson_array[0]}/$folder"
    notify-send -t 5000 "Folder $folder/ created"
}

original_filename=$(basename -- "$file")
main_extension="${original_filename##*.}"

filename_with_extension="$new_filename.$main_extension"


[ -e "${lesson_array[0]}/$folder/$filename_with_extension" ] && {
		overwrite=$(echo -e "No\nYes" | dmenu -c -p "Overwrite File?")
		[ "$overwrite" == "No" ] && {
				notify-send "Move Canceled"
				exit
		}
}

# Move file, update timestamp and then notify user
mv -i "$download_dir/$file" "${lesson_array[0]}/$folder/$filename_with_extension" && touch "${lesson_array[0]}/
$folder/$filename_with_extension" && notify-send -t 3000 "File moved" 

[ "$main_extension" == "pdf" ] && {
    exiftool -overwrite_original -Title="" "${lesson_array[0]}/$folder/$filename_with_extension"
}





