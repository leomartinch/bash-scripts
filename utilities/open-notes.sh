#!/bin/bash

# Script to open and create notes in notes folder
# Leo Martin (2025)

### VARIABLES ###
notes_folder="$HOME/documents/notes"
# add better folder search

### SCRIPT ###
full_path=$(find "$notes_folder" -type f -iname '*.txt' -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
selected_note=$(echo -e "New\n$full_path" | sed 's:.*/::' | dmenu -c -bw 2 -l 10 -i -p "Select Note: ")

case $selected_note in
	New)
		filename="$(echo "" | dmenu -c -p "Name Note: " <&-)"
		filename="${filename// /-}" # replace the whitespaces with '-'
		
		# append current date to filename with ..d command
		[[ "$filename" == *..d* ]] && {
			current_date=$(date +%Y-%m-%d)
			filename="${filename//..d/}-$current_date"
		}

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
		# open note in neovim in new terminal
		file_path=$(echo "$full_path" | grep "/$selected_note$")
		dir_path=$(dirname "$file_path")
		st -e bash -c "cd '$dir_path'; nvim '$selected_note'; exec bash"
		;;
	
	*)
		# cancel script (esc key pressed)
		exit
		;;

esac
