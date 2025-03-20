#!/bin/bash

# Script to open files in various programms in the terminal

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
				local folder=$(echo -e "Create New" | dmenu -c -bw 2 -noi -i -p "Select Folder: ")
		} || {
				local folder=$(echo -e "$available_subfolders" | dmenu -c -l 5 -i -p "Select Folder: ")
		}

		[ -z "$folder" ] && {
				echo "$all_folder"
				exit
		}

		[ "$folder" == "Create New" ] && {
				folder="$(echo "" | dmenu -c -p "Name Folder: " <&-)"
		}

		folder="${folder// /-}" 

		[ -d "$current_dir/$all_folder/$folder" ] || { # create folder if does not exist already
		    mkdir "${lesson_array[0]}/$all_folder/$folder"
		    notify-send -t 5000 "Folder $folder/ created"
		}

		all_folder+="$folder/"	
		available_subfolders=$(ls -dt "$current_dir/$all_folder"*/ 2>/dev/null)
		
    done
	echo "$all_folder"

}

