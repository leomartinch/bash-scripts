#!/bin/bash

# Script to open files in various programms
# Leo Martin (2024)


### VARIABLES ###
source "$HOME/.scripts/get-school-lesson.sh"

download_dir="$HOME/downloads"
lesson_log_file="$HOME/.scripts/.set_lesson.log"
default_files="$HOME/.scripts/defaults"


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


### SCRIPT ###

[ -s "$lesson_log_file" ] && { # if lesson log file is not empty
    lesson_name="$(cat "$lesson_log_file")"
    declare -n ref_array="$lesson_name"
    lesson_array=("${ref_array[@]}")
} || {
    get_current_lesson
}


# special lesson requirements
if [ "${lesson_array[1]}" == "Informatik" ]; then
	software_choice="$(echo -e "okular\npython\nnvim\nthunar\nteams\nzathura\nqnote\nlibreoffice" | dmenu -c -bw 2 -l 10 -i -p "Open File in: ")"

elif [ "${lesson_array[1]}" == "Maturaarbeit" ]; then
	software_choice="$(echo -e "zathura\nokular\nnvim\nokular\nthunar\nlatex\npython\nlibreoffice\nqnote" | dmenu -c -l 10 -bw 2 -i -p "Open File in: ")"

elif [ "${lesson_array[1]}" == "Physik Praktikum" ]; then
	software_choice="$(echo -e "python\nzathura\nokular\nthunar\nlatex\nnvim\nteams\nlibreoffice\nqnote" | dmenu -c -bw 2 -l 10 -i -p "Open File in: ")"

elif [ "${lesson_array[1]}" == "No Lesson" ]; then
	echo "No Lesson" | dmenu -c -noi
	exit

elif [ "${lesson_array[1]}" == "Weekend" ]; then
	echo "Weekend" | dmenu -c -noi
	exit

else
	software_choice="$(echo -e "okular\nxournal\nnvim\nteams\nthunar\nzathura\npython\nqnote\nlatex\nlibreoffice\nonedrive" | dmenu -c -bw 2 -l 10 -i -p "Open File in: ")"
fi


case $software_choice in
	okular)
		# open .pdf files in okular
		full_path=$(find ${lesson_array[0]} -type f -iname '*.pdf' -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo "$full_path" | sed 's:.*/::' | dmenu -c -l 10 -bw 2 -i -p "Select File: ")
		[ -z "$selected_file" ] && {
			exit 1
		}
		
		file_path=$(echo "$full_path" | grep "/$selected_file$")
		okular "$file_path"
		;;

	xournal)
		# open .pdf or .xopp files in xournal
		full_path=$(find ${lesson_array[0]} -type f \( -iname '*.pdf' -o -iname '*.xopp' \) -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo -e "Create New\n$full_path" | sed 's:.*/::' | dmenu -c -l 10 -i -p "Select File: ")
		[ -z "$selected_file" ] && {
			exit 1
		}

		[ "$selected_file" == "Create New" ] && {
				filename="$(echo "" | dmenu -c -p "Name File: " <&-)"
				filename="${filename// /-}" # replace the whitespaces with '-'

				folder=$(select_folder)
				cp "$default_files/xournal_default.xopp" "${lesson_array[0]}/$folder/$filename.xopp" 
				xournalpp "${lesson_array[0]}/$folder$filename.xopp" 
		} || {
				file_path=$(echo "$full_path" | grep "/$selected_file$")
				xournalpp "$file_path"
		}
		;;

	nvim)
		# open .txt file or create new in nvim
		full_path=$(find ${lesson_array[0]} -type f -iname '*.txt' -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo -e "Create New\n$full_path" | sed 's:.*/::' | dmenu -c -l 10 -i -p "Select File: ")
		[ -z "$selected_file" ] && {
			exit 1
		}

		[ "$selected_file" == "Create New" ] && {
			filename="$(echo "" | dmenu -c -p "Name File: " <&-)"
			filename="${filename// /-}" # replace the whitespaces with '-'

			folder=$(select_folder)

			st -e bash -c "cd '${lesson_array[0]}'/'$folder'; nvim '$filename'.txt; exec bash" 
		} || {
			file_path=$(echo "$full_path" | grep "/$selected_file$")
			dir_path=$(dirname "$file_path")
			st -e bash -c "cd '$dir_path'; nvim '$selected_file'; exec bash"	
		}
		;;

	thunar)
		# open thunar in chosen subfolder (press esc for home dir of current lesson)
		folder=$(select_folder)
		thunar "${lesson_array[0]}/$folder"
		;;

	teams)
		# open teams in librewolf
		[ "${lesson_array[1]}" == "EWR" ] && {
		    librewolf "https://www.microsoft365.com/launch/onenote?auth=2" # open one note
		} || {
		    librewolf "https://teams.microsoft.com/v2/"
		}
		;;
	
    onedrive)
		# open onedrive in librewolf
		librewolf "https://eduzh-my.sharepoint.com/"
		;;

	python)
		# open and run or create new .py file
		full_path=$(find ${lesson_array[0]} -type f -iname '*.py' -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo -e "Create New\n$full_path" | sed 's:.*/::' | dmenu -c -l 10 -i -p "Select Script: ")

		[ -z "$selected_file" ] && {
			exit
		}

		[ "$selected_file" == "Create New" ] && {
			filename="$(echo "" | dmenu -c -p "Name Python Script: " <&-)"
			filename="${filename// /-}" # replace the whitespaces with '-'

			folder=$(select_folder)

			st -e bash -c "cd '${lesson_array[0]}'/'$folder'; nvim '$filename'.py; exec bash" 
		} || {
			script_choice="$(echo -e "edit\nrun\ncopy" | dmenu -c -bw 2 -noi -i -p "Action: ")"
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
		# open file in libreoffice
		full_path=$(find ${lesson_array[0]} -type f \( -iname '*.txt' -o -iname '*.odt' -o -iname '*.docx' \) -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo -e "Create New\n$full_path" | sed 's:.*/::' | dmenu -c -l 10 -i -p "Select File: ")
		[ -z "$selected_file" ] && {
			exit 1
		}

		[ "$selected_file" == "Create New" ] && {
			filename="$(echo "" | dmenu -c -p "Name File: " <&-)"
			filename="${filename// /-}"	

			[ -z "$filename" ] && {
				exit
			}
			
			file_type="$(echo -e "odt\ntxt" | dmenu -c -i -p "Filetype: ")"

			folder=$(select_folder)

			touch "${lesson_array[0]}/$folder/$filename.$file_type"  
			libreoffice "${lesson_array[0]}/$folder/$filename.$file_type" 
		} || {
			file_path=$(echo "$full_path" | grep "/$selected_file$")
			dir_path=$(dirname "$file_path")
			setsid -f libreoffice "$dir_path/$selected_file"
		}
		;;
		
	qnote)
		# creat .txt note
		st -e bash -c "cd '${lesson_array[0]}'; nvim note.txt; exec bash"	
		;;

    latex)
		# open .tex file and the pdf or create new in nvim
		full_path=$(find ${lesson_array[0]} -type f -iname '*.tex' -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo -e "Create New\n$full_path" | sed 's:.*/::' | dmenu -c -l 10 -i -p "Select File: ")
		[ -z "$selected_file" ] && exit

				
		[ "$selected_file" == "Create New" ] && {
			filename="$(echo "" | dmenu -c -p "Name File: " <&-)"
			filename="${filename// /-}" # replace the whitespaces with '-'
		
			folder=$(select_folder)
		    cp "$default_files/template.tex" "${lesson_array[0]}/$folder/$filename.tex"

		    st -e bash -c "cd '${lesson_array[0]}'/'$folder'; nvim '$filename'.tex; exec bash"# & \

		} || {
			file_path=$(echo "$full_path" | grep "/$selected_file$")
		    file_basename=$(basename "$selected_file" .tex)
		    dir_path=$(dirname "$file_path")


		    tex_choice="$(echo -e "all\npdf\ntex\nbib" | dmenu -c -bw 2 -noi -i -p "Action: ")"
		    case $tex_choice in
				all)
				    st -e bash -c "cd '$dir_path'; nvim '$file_basename'.tex; exec bash" & \
				    zathura "$dir_path/$file_basename.pdf"
				    ;;
				pdf)
				    zathura "$dir_path/$file_basename.pdf"
				    ;;
				tex)
				    st -e bash -c "cd '$dir_path'; nvim '$file_basename'.tex; exec bash" & \
		    	    ;;
				bib)
				    st -e bash -c "cd '$dir_path'; nvim sources.bib; exec bash" & \
				    ;;
 
				*)
				    exit
				    ;;
		    esac

		}
		;;

    zathura)
		# open .pdf files in okular
		full_path=$(find ${lesson_array[0]} -type f -iname '*.pdf' -printf '%T@ %p\n' | sort -n -r | cut -d' ' -f2-)
		selected_file=$(echo "$full_path" | sed 's:.*/::' | dmenu -c -l 10 -bw 2 -i -p "Select File: ")
		[ -z "$selected_file" ] && {
			exit 1
		}
		
		file_path=$(echo "$full_path" | grep "/$selected_file$")
		zathura "$file_path"
		;;


	*)
		# cancel script (esc key pressed)
		exit
		;;
esac

	





