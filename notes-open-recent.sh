#!/bin/bash

# Script to open notes from notes folder


### VARIABLES ###
notes_folder="/home/leomartin/documents/notes"



### SCRIPT ###

full_path=$(find "$notes_folder" -type f -iname '*.txt' -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
selected_note=$(echo -e "New\n$full_path" | sed 's:.*/::' | dmenu -c -l 5 -i -p "Choose Note or create new: ")

case $selected_note in
	New)
		# Create new Note
		filename="$(echo "" | dmenu -c -p "Name Note: " <&-)"
		filename="${filename// /-}" # replace the whitespaces with '-'
		
		# Append current date to filename
		[[ "$filename" == *..d* ]] && {
			current_date=$(date +%Y-%m-%d)
			filename="${filename//..d/}-$current_date"
		}

		# sorts the subfolders by when they were last used
		available_subfolders=$(ls -dt "$notes_folder"/*/ 2>/dev/null)

		[ -n "$available_subfolders" ] && {
			available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename)
		}

		folder=$(echo -e "$available_subfolders" | dmenu -c -l 5 -i -p "Select Folder: ")

		[ -d "$notes_folder/$folder" ] || {
			mkdir "${lession_array[0]}/$folder"
    			notify-send -t 5000 "Folder $folder/ created"
		}

		st -e bash -c "cd '$notes_folder'; nvim '$filename'.txt; exec bash"
		;;
	
	*txt)
		# Open Note in Neovim in new Terminal
		file_path=$(echo "$full_path" | grep "/$selected_note$")
		dir_path=$(dirname "$file_path")
		st -e bash -c "cd '$dir_path'; nvim '$selected_note'; exec bash"
		;;
	
	*)
		# Cancel Script (esc key pressed)
		exit
		;;

esac



	
	





