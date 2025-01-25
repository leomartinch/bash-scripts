#!/bin/bash

# Script to open files in various programms
# Leo Martin (2024)


### VARIABLES ###
source "/home/leomartin/.scripts/get-school-lesson.sh"

download_dir="/home/leomartin/downloads"
lesson_log_file="/home/leomartin/.scripts/.set_lesson.log"


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
	available_subfolders=$(ls -dt "${lesson_array[0]}"/*/ 2>/dev/null)
		
	[ -n "$available_subfolders" ] && {
		available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename)
	}

	folder=$(echo -e "$available_subfolders" | dmenu -c -l 5 -i -p "Select Folder: ")

	#[ -d "${lession_array[0]}/$folder

	[ -d "${lesson_array[0]}/$folder" ] || {
		mkdir "${lesson_array[0]}/$folder"
		notify-send -t 5000 "Folder $folder/ created"
	}
}



### SCRIPT ###

[ -s "$lesson_log_file" ] && { # if lesson log file is not empty
    lesson_name="$(cat "$lesson_log_file")"
    declare -n ref_array="$lesson_name"
    lesson_array=("${ref_array[@]}")
} || { # if lesson log file is empty
    get_current_lesson
}


# special lesson requirements
if [ "${lesson_array[1]}" == "Informatik" ]; then
	software_choice="$(echo -e "python\nnvim\nokular\nxournal\nteams\nthunar\nlibreoffice" | dmenu -c -l 10 -i -p "Open File in: ")"

#elif [ "${lesson_array[1]}" == "" ]; then
#	software_choice="$(echo -e "python\nnvim\nokular\nxournal\nteams\nthunar\nlibreoffice" | dmenu -c -l 10 -i -p "Open File in: ")"

else
	software_choice="$(echo -e "okular\nxournal\nnvim\nteams\nthunar\npython\nlibreoffice" | dmenu -c -l 10 -i -p "Open File in: ")"
fi


case $software_choice in
	okular)
		# Open .pdf files in okular
		full_path=$(find ${lesson_array[0]} -type f -iname '*.pdf' -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo "$full_path" | sed 's:.*/::' | dmenu -c -l 5 -i -p "Select File: ")
		[ -z "$selected_file" ] && {
			exit 1
		}

		file_path=$(echo "$full_path" | grep "/$selected_file$")
		okular "$file_path"
		;;

	xournal)
		# Open .pdf or .xopp files in xournal
		full_path=$(find ${lesson_array[0]} -type f \( -iname '*.pdf' -o -iname '*.xopp' \) -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo "$full_path" | sed 's:.*/::' | dmenu -c -l 5 -i -p "Select File: ")
		[ -z "$selected_file" ] && {
			exit 1
		}

		file_path=$(echo "$full_path" | grep "/$selected_file$")
		xournalpp "$file_path"
		;;

	nvim)
		# Open .txt file or create new in nvim
		full_path=$(find ${lesson_array[0]} -type f -iname '*.txt' -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo -e "Create New\n$full_path" | sed 's:.*/::' | dmenu -c -l 5 -i -p "Select File: ")
		[ -z "$selected_file" ] && {
			exit 1
		}

		[ "$selected_file" == "Create New" ] && {
			filename="$(echo "" | dmenu -c -p "Name File: " <&-)"
			filename="${filename// /-}" # replace the whitespaces with '-'

			select_folder

			st -e bash -c "cd '${lesson_array[0]}'/'$folder'; nvim '$filename'.txt; exec bash" 
		} || {
			file_path=$(echo "$full_path" | grep "/$selected_file$")
			dir_path=$(dirname "$file_path")
			st -e bash -c "cd '$dir_path'; nvim '$selected_file'; exec bash"	
		}
		;;

	thunar)
		# Open thunar in chosen subfolder (if pressed esc during file choosing then it goes to the home dir of the current lesson)
		select_folder
		thunar "${lesson_array[0]}/$folder"
		;;

	teams)
		# Open teams in firefox
		[ "${lesson_array[1]}" == "EWR" ] && {
			firefox "https://www.microsoft365.com/launch/onenote?auth=2" # open one note
		} || {
			firefox "https://teams.microsoft.com/v2/"
		}
		;;
	
	python)
		# Open and run or create new .py file
		full_path=$(find ${lesson_array[0]} -type f -iname '*.py' -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo -e "Create New\n$full_path" | sed 's:.*/::' | dmenu -c -l 5 -i -p "Run Script or create new: ")
		[ -z "$selected_file" ] && {
			exit 1
		}

		[ "$selected_file" == "Create New" ] && {
			filename="$(echo "" | dmenu -c -p "Name Python Script: " <&-)"
			filename="${filename// /-}" # replace the whitespaces with '-'

			select_folder

			st -e bash -c "cd '${lesson_array[0]}'/'$folder'; nvim '$filename'.py; exec bash" 
		} || {
			script_choice="$(echo -e "edit\nrun\ncopy" | dmenu -c -i -p "Action: ")"
			file_path=$(echo "$full_path" | grep "/$selected_file$")
			dir_path=$(dirname "$file_path")

			case $script_choice in
			edit)
				st -e bash -c "cd '$dir_path'; nvim '$selected_file'; exec bash"
				;;
			run)
				# run the script and add the run command to terminal history
				st -e bash -c "cd '$dir_path'; echo 'python \"$selected_file\"' >> ~/.bash_history; exec bash"
				;;
			copy)
				new_filename="$(echo -e "increment" | dmenu -c -i -p "Name Copy: ")"
				
				[ -z "$new_filename" ] && {
					exit
				}

				[ "$new_filename" == "increment" ] && {
					base="${selected_file%.py}"
					number="${base##*-}"

					if [[ "$number" =~ ^[0-9]+$ ]]; then # if there is already a number, increment 
						base="${base%-*}"
    						new_filename="${base}-$((number + 1)).py"
					else
						new_filename="${base}-1.py" # add 1 if there is no number
					fi
				} || {	
					new_filename="${new_filename// /-}.py"
				}
				cp "$dir_path/$selected_file" "$dir_path/$new_filename"  
				st -e bash -c "cd '$dir_path'; nvim '$new_filename'; exec bash"
				;;

			*)
				exit
				;;
			esac
		}
		;;

	libreoffice)
		# Open file in libreoffice
		full_path=$(find ${lesson_array[0]} -type f \( -iname '*.txt' -o -iname '*.odt' -o -iname '*.docx' \) -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo -e "Create New\n$full_path" | sed 's:.*/::' | dmenu -c -l 5 -i -p "Select File: ")
		[ -z "$selected_file" ] && {
			exit 1
		}

		[ "$selected_file" == "Create New" ] && {
			filename="$(echo "" | dmenu -c -p "Name File: " <&-)"
			filename="${filename// /-}"	

			[ -z "$filename" ] && {
				exit 1
			}
			
			file_type="$(echo -e "odt\ntxt" | dmenu -c -i -p "Filetype: ")"

			select_folder

			touch "${lesson_array[0]}/$folder/$filename.$file_type"  
			libreoffice "${lesson_array[0]}/$folder/$filename.$file_type" 
		} || {
			file_path=$(echo "$full_path" | grep "/$selected_file$")
			dir_path=$(dirname "$file_path")
			setsid -f libreoffice "$dir_path/$selected_file"
		}
		;;

	*)
		# Cancel script (esc key pressed)
		exit
		;;
esac

	





