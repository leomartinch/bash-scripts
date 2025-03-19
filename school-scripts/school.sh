#!/bin/bash

# Script to open files in various programms in the terminal
# Leo Martin (2025)


### VARIABLES ###
source "$HOME/.scripts/get-school-lesson.sh"

download_dir="$HOME/downloads"
lesson_log_file="$HOME/.scripts/.set_lesson.log"
default_files="$HOME/.scripts/defaults"
last_visited_dir_file="$HOME/.scripts/.last_visited_dir"


cd_script_dir="$HOME/.scripts/school-cd-script.sh"
set_lesson_log_file="$HOME/.scripts/.set_lesson.log"

help_file="$HOME/.scripts/school-script-instructions.txt"


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



function select_folderrr {
    current_dir="${lesson_array[0]}"
	available_subfolders=$(ls -dt "$current_dir"/*/ 2>/dev/null)
	local all_folder=""
		
	while : 
	do
		available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename)

		[ -z "$available_subfolders" ] && {	
				read -p "Create new folder: $all_folder" folder
				#local folder=$(echo "Create New")
		} || {
				read -p "Create new folder: $all_folder" folder
				#local folder=$(echo -e "$available_subfolders" | dmenu -c -l 5 -i -p "Select Folder: ")
		}

		#[ -z "$folder" ] && { # exit statement
		#		echo "$all_folder"
		#		exit
		#}

		#[ "$folder" == "Create New" ] && {
		#		folder="$(echo "" | dmenu -c -p "Name Folder: " <&-)"
		#}

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



select_folderi() {
		folder="my_val"
}


function school {

### SCRIPT ###

[ -s "$lesson_log_file" ] && { # if lesson log file is not empty
    lesson_name="$(cat "$lesson_log_file")"
    declare -n ref_array="$lesson_name"
    lesson_array=("${ref_array[@]}")
} || {
    get_current_lesson
}


case $# in
	0)
		# cd into last visited subfolder, if last visited subfolder not exist 
		[ "${lesson_array[1]}" == "No Lesson" ] && { echo "No Lesson currently!"; return; }

		last_visited_dir="$(get_last_dir)"
		
		[ -d "${lesson_array[0]}/$last_visited_dir" ] && {
			source "$cd_script_dir" "${lesson_array[0]}/$last_visited_dir"
		} || {
			source "$cd_script_dir" "${lesson_array[0]}" # if directory does not exist go to base folder
		}
		;;


	1)	
		# cd into home directory
		[ "$1" == "test" ] && {
				folder="$(select_folder)"
				#select_folderi
				echo "$folder"	
		}

		# cd into home directory
		[ "$1" == "." ] && {
			source "$cd_script_dir" "${lesson_array[0]}"
		}
		
		# cd into the download folder
		[ "$1" == "d" ] && {
			source "$cd_script_dir" "$download_dir"
		}

		# set current lesson back to normal
		[ "$1" == "lset" ] && {
			> "$set_lesson_log_file"
			echo "Current Lesson reset"
		}

		# open thunar in the last visited subfolder of the current directory
		[ "$1" == "thunar" ] && {
		    last_visited_dir=$(get_last_dir)
			source "$cd_script_dir" "${lesson_array[0]}/$last_visited_dir"
			thunar "${lesson_array[0]}/$last_visited_dir"
		}

		# display how much time is left in the current lesson
		[ "$1" == "time" ] && {			
			[ "${lesson_array[1]}" == "No Lesson" ] || [ "${lesson_array[1]}" == "Weekend" ] || [ -s "$set_lesson_log_file" ] && {	
				echo "No Lesson currently!"
				return
			}
			
			current_seconds=$(expr $(date +%S))	
			seconds_left=$((60 - $current_seconds))
				
			[ "$seconds_left" -eq 60 ] && {
				minutes_left=$((45 - $time_in_lesson))
				seconds_left=0
			} || {
				minutes_left=$((44 - $time_in_lesson))
			}

			seconds_left_formatted=$(printf "%02d" "$seconds_left")
			echo "Time Left: [$minutes_left:$seconds_left_formatted]"
		}

		# display the current lesson
		[ "$1" == "l" ] && {
			echo "Current Lesson: $(tput bold; tput setaf 11)${lesson_array[1]}"
		}
		
		# display the last viewed subfolder of the current lesson
		[ "$1" == "ldir" ] && {
			last_visited_dir=$(get_last_dir)
			echo "Last visited subfolder: $(tput bold; tput setaf 13)$last_visited_dir/"
		}

		# display manual for shell script
		[ "$1" == "-h" ] || [ "$1" == "--help" ] && {
			cat "$help_file"
		}
		;;


	2)	
		# change last visited subfolder 
		[ "$1" == "ldir" ] && {	
			[ -d "${lesson_array[0]}/$2" ] || {
				mkdir "${lesson_array[0]}/$2"
				echo "Directory created: $(tput bold; tput setaf 13)$2/"
			}

			write_last_dir "$2"

			echo "$(tput sgr0)Last visited subfolder:$(tput bold; tput setaf 13) $2/"
			source "$cd_script_dir" "${lesson_array[0]}/$2"

		}

		# set current lesson and overwrite get_current_lesson script
		[ "$1" == "lset" ] && {
			echo "$2" > "$set_lesson_log_file"
			echo "Current Lesson: $(tput bold; tput setaf 11)$2"
		}

		# cd into a chosen subfolder
		[ "$1" == "cd" ] && {
			source "$cd_script_dir" "${lesson_array[0]}/$2"
		}

		# open file in neovim in last visited subfolder of current directory
		[ "$1" == "vim" ] && {
			source "$cd_script_dir" "${lesson_array[0]}/$last_visited_dir"
			[ -f "$2" ] && {
				nvim "$2"
			} || {
				nvim "$2.txt"
			}
		}

		# open thunar in the current lesson directory
		[ "$1" == "thunar" ] && [ "$2" == "." ] && {
			source "$cd_script_dir" "${lesson_array[0]}"
			thunar "${lesson_array[0]}"
		}

		# move and rename file to last used subfolder
		[ -f "$1" ] && [ "$2" == "-mv" ] && {
			read -e -p "$(tput bold; tput setaf 9)[Rename] $(tput setaf 11)$1$(tput setaf 15):$(tput sgr0) " new_filename

			[ -z "$new_filename" ] && { # if pressed enter, dont rename file
				new_filename="${1%.*}"
			}

			original_filename=$(basename -- "$1")
			main_extension="${original_filename##*.}"
			filename_with_extension="$new_filename.$main_extension"
			# needs design improvement
			echo "$(tput bold; tput setaf 10)  =====> $filename_with_extension$(tput setab 0)"
		
			#last_visited_dir=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			last_visited_dir=$(get_last_dir)
			mv "$1" "${lesson_array[0]}/$last_visited_dir/$filename_with_extension"

			source "$cd_script_dir" "${lesson_array[0]}/$last_visited_dir"
			tput sgr0
		}
		;;



	3)

		# move and rename file to a subfolder, if it does not exist, create one
		[ -f "$1" ] && [ "$2" == "-mv" ] && {
			read -e -p "$(tput bold; tput setaf 9)[Rename] $(tput setaf 11)$1$(tput setaf 15):$(tput sgr0) " new_filename

			[ -z "$new_filename" ] && { # if pressed enter, dont rename file
				new_filename="${1%.*}"
			}

			original_filename=$(basename -- "$1")
			main_extension="${original_filename##*.}"
			filename_with_extension="$new_filename.$main_extension"
			# needs design improvement
			echo "$(tput bold; tput setaf 10)  =====> $filename_with_extension$(tput setab 0)"

			[ -d "${lesson_array[0]}/$3" ] || {
				mkdir "${lesson_array[0]}/$3"
				echo "Folder created: $(tput bold; tput setaf 13)$3/"
			}

			mv "$1" "${lesson_array[0]}/$3/$filename_with_extension"	
			source "$cd_script_dir" "${lesson_array[0]}/$3"

			#dir_variable_name="${lesson_array[2]}"
			#grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s/^$dir_variable_name=.*/$dir_variable_name=$3/" "$last_visited_dir_file"
			write_last_dir "$3"

			tput sgr0
	
		}




		# cd into a chosen sub-subfolder
		[ "$1" == "cd" ] && {
			[ -d "${lesson_array[0]}/$2/$3" ] && {
    				source "$cd_script_dir" "${lesson_array[0]}/$2/$3"
			} || {
				echo "Error: Subfolder does not exist!"
			}
		}

		# open or create txt file in neovim in chosen directory
		[ "$1" == "vim" ] && {
			[ "$2" == "-" ] && {
				subfolder=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			} || {	
				subfolder="$2"
			}
			source "$cd_script_dir" "${lesson_array[0]}/$subfolder"

			[ -f "$3" ] && {
				nvim "$3"
			} || {
				nvim "$3.txt"
			}
		}
	
		# open file in chosen subfolder of current lesson in okular
		[ "$1" == "okular" ] && {
			[ "$2" == "-" ] && {
				folder=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			} || {
				folder="$2"
			}
			source "$cd_script_dir" "${lesson_array[0]}/$folder"
			okular "${lesson_array[0]}/$folder/$3"
		}

		# open file in chosen subfolder of current lesson in xournal
		[ "$1" == "xournal" ] && {
			[ "$2" == "-" ] && {
				folder=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			} || {
				folder="$2"
			}
			source "$cd_script_dir" "${lesson_array[0]}/$folder"
			xournalpp "${lesson_array[0]}/$folder/$3"
		}


		# move and rename file to last used subfolder of current lesson and then open in okular or xournal
		[ "$1" == "xournal-" ] || [ "$1" == "okular-" ] && [ -f "$2" ] && [ "$3" == "-mv" ] && {
			read -e -p "$(tput bold; tput setaf 9)[Rename] $(tput setaf 11)$2$(tput setaf 15):$(tput sgr0) " new_filename

			[ -z "$new_filename" ] && { # if pressed enter, dont rename file
				new_filename="${1%.*}"
			}

			original_filename=$(basename -- "$2")
			main_extension="${original_filename##*.}"
			filename_with_extension="$new_filename.$main_extension"

			# needs design improvement
			echo "$(tput bold; tput setaf 10)  =====> $filename_with_extension$(tput setab 0)"

			#last_visited_dir=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			last_visited_dir=$(get_last_dir)
			mv "$2" "${lesson_array[0]}/$last_visited_dir/$filename_with_extension"


			source "$cd_script_dir" "${lesson_array[0]}/$last_visited_dir"

			[ "$1" == "okular-" ] && {
				okular "$filename_with_extension"
			} || { 
				xournalpp "$filename_with_extension"
			}
		}

		# EXPERIMENTAL: could break other commands
		# change last visited sub subfolder 
		[ "$1" == "ldir" ] && {
			[ -d "${lesson_array[0]}/$2/$3" ] || {
				mkdir "${lesson_array[0]}/$2/$3"
				echo "Directory created: $(tput bold; tput setaf 13)$3/"
			}

			sub_sub_dir="$2/$3"

			dir_variable_name="${lesson_array[2]}"
			grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s|^$dir_variable_name=.*|$dir_variable_name=$sub_sub_dir|" "$last_visited_dir_file"

			echo "$(tput sgr0)Last visited sub-subfolder:$(tput bold; tput setaf 13) $2/$3/"
			source "$cd_script_dir" "${lesson_array[0]}/$2/$3"

		}
		;;

	
		*)
				echo "Error!"
				;;
esac


}


#====tests auto completes

function sorted_file_completion {
	files=$(find . -maxdepth 1 -type f -print0 | xargs -0 ls -t | xargs -0 -I {} basename "{}" | sed 's/ /\\\ /g')
	mapfile -t COMPREPLY < <(compgen -W "$files" -- "${COMP_WORDS[COMP_CWORD]}")
}



function something_file_completion {	

	files=$(find . -maxdepth 1 -type f -print0 | xargs -0 -I {} basename "{}")
	files_esc=()

	while IFS= read -r file; do
		file_esc=$(echo "$file" | sed 's/\\/\\\\/g')
		files_esc+=("$file_esc")

	done <<< "$files"

	local files_joined="${files_esc[*]}"

	mapfile -t COMPREPLY < <(compgen -W "$files_joined" -- "${COMP_WORDS[COMP_CWORD]}")
}




##====DIFFERENT AUTO COMPLETES

# remove files from the auto complete that have already been chosen, $1=directory
function multiple_file_completion {	
	files=$(find . -maxdepth 1 -type f -print0 | xargs -0 -I {} basename "{}" | sed 's/ /\\\ /g')

	for remove_file in $COMP_LINE; do
		files=$(echo "$files" | grep -v "^$remove_file$")
	done

	mapfile -t COMPREPLY < <(compgen -W "$files" -- "${COMP_WORDS[COMP_CWORD]}")
}

# auto complete subfolders in a directory, $1=directory
function standard_subfolder_completion {
	available_subfolders=$(ls -d "$1"/*/ 2>/dev/null)
	[ -n "$available_subfolders" ] && {
		available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename)
	} 
	COMPREPLY=($(compgen -W "$available_subfolders" -- "${COMP_WORDS[COMP_CWORD]}"))	
}

# auto complete all files in a directory, $1=directory / $2=filetype
function standard_file_completion {
	[ "$2" == "all" ] && {
		filetype=(-type f)
	}
	[ "$2" == "pdf" ] && {
		filetype=(-type f -iname '*.pdf')
	}
	[ "$2" == "txt" ] && {
		filetype=(-type f -iname '*.txt')
	}
	[ "$2" == "pdf_txt" ] && {
		filetype=(-type f \( -iname '*.pdf' -o -iname '*.txt' \))
	}
	[ "$2" == "pdf_xopp" ] && {
		filetype=(-type f \( -iname '*.pdf' -o -iname '*.xopp' \))
	}

	files=$(find "$1" -maxdepth 1 "${filetype[@]}" -print0 | xargs -0 -I {} basename "{}" | sed 's/ /\\\ /g')
	mapfile -t COMPREPLY < <(compgen -W "$files" -- "${COMP_WORDS[COMP_CWORD]}")
}


function default_completion {

##========== usage convention:
# 	first write the command, then as first argument [directory], then the command for special searches for pdf for example


	# if no argument written, only show files and not custom commands
	if [ -z "${COMP_WORDS[1]}" ]; then
		standard_file_completion "." "all"



	elif [ "${COMP_WORDS[1]}" == "x" ]; then
		#remove_last_file_completion "$COMP_LINE"
		multiple_file_completion # "." "txt"
		



	# ldir
	elif [ "${COMP_WORDS[1]}" == "ldir" ]; then
		[ "$COMP_CWORD" -gt 3 ] && {
			COMPREPLY=() # this command cannot have more arguments
		} || {
			standard_subfolder_completion "${lesson_array[0]}"
		}
		[ "$COMP_CWORD" -eq 3 ] && {
			standard_subfolder_completion "${lesson_array[0]}/${COMP_WORDS[2]}"
		}

	# lset
	elif [ "${COMP_WORDS[1]}" == "lset" ]; then
		[ "$COMP_CWORD" -gt 2 ] && {
			COMPREPLY=() # this command cannot have more arguments
		} || {
			available_lessons="geschichte informatik deutsch francais english physik physik_praktikum wirtschaft mathematik"
			COMPREPLY=($(compgen -W "$available_lessons" -- "${COMP_WORDS[COMP_CWORD]}"))
		}
		
	# cd
	elif [ "${COMP_WORDS[1]}" == "cd" ]; then
		[ "$COMP_CWORD" -gt 3 ] && {
			COMPREPLY=() # this command cannot have more arguments
		} || {
			standard_subfolder_completion "${lesson_array[0]}"
		}
		[ "$COMP_CWORD" -eq 3 ] && {
			standard_subfolder_completion "${lesson_array[0]}/${COMP_WORDS[2]}"
		}

	# -mv
	elif [ "${COMP_WORDS[COMP_CWORD -1]}" == "-mv" ]; then
		standard_subfolder_completion "${lesson_array[0]}"

#======= Programms
	# vim
	elif [ "${COMP_WORDS[1]}" == "vim" ]; then # show subfolders, then only show txt files
		[ "$COMP_CWORD" -eq 2 ] && {
			standard_subfolder_completion "${lesson_array[0]}"
		}
		[ "$COMP_CWORD" -eq 3 ] && {
			[ "${COMP_WORDS[2]}" == "-" ] && {
				last_visited_subfolder=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
				standard_file_completion "${lesson_array[0]}/$last_visited_subfolder" "txt"
			} || {
				standard_file_completion "${lesson_array[0]}/${COMP_WORDS[2]}" "txt"
			}
		}
	
		[ "$COMP_CWORD" -gt 3 ] && {
			COMPREPLY=()
		}

	# open file in xournal, okular
	elif [ "${COMP_WORDS[1]}" == "xournal" ] || [ "${COMP_WORDS[1]}" == "okular" ]; then
		#last_visited_subfolder=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
		last_visited_subfolder=$(get_last_dir)

		[ "$COMP_CWORD" -gt 3 ] && {
			COMPREPLY=()
		}
		[ "$COMP_CWORD" -eq 2 ] && {
			standard_subfolder_completion "${lesson_array[0]}"
		}

		[ "$COMP_CWORD" -eq 3 ] && [ "${COMP_WORDS[1]}" == "okular" ] && {
			[ "${COMP_WORDS[2]}" == "-" ] && { # if user wants to user last visited subfolder
				standard_file_completion "${lesson_array[0]}/$last_visited_subfolder" "pdf"
			} || {	
				standard_file_completion "${lesson_array[0]}/${COMP_WORDS[2]}" "pdf"
			}
		}
		[ "$COMP_CWORD" -eq 3 ] && [ "${COMP_WORDS[1]}" == "xournal" ] && {
			[ "${COMP_WORDS[2]}" == "-" ] && { # if user wants to user last visited subfolder
				standard_file_completion "${lesson_array[0]}/$last_visited_subfolder" "pdf_xopp"
			} || {	
				standard_file_completion "${lesson_array[0]}/${COMP_WORDS[2]}" "pdf_xopp"
			}
		}

	# move and rename file, then open in xournal, okular
	elif [ "${COMP_WORDS[1]}" == "xournal-" ] || [ "${COMP_WORDS[1]}" == "okular-" ]; then
		[ "$COMP_CWORD" -eq 2 ] && {

			[ "${COMP_WORDS[1]}" == "xournal-" ] && {
				standard_file_completion "." "pdf_xopp" # in local directory
			} || {
				standard_file_completion "." "pdf"
			}
		}
		[ "$COMP_CWORD" -eq 3 ] && {
			COMPREPLY=("-mv")
		}
		[ "$COMP_CWORD" -eq 4 ] && {
			standard_subfolder_completion "${lesson_array[0]}"
		}
	
		[ "$COMP_CWORD" -gt 4 ] && {
			COMPREPLY=()
		}


	# for large quantity of files, remove the ones from the auto complete that have already been chosen
	elif [ -f "${COMP_WORDS[1]}" ] && [ -f "${COMP_WORDS[2]}" ]; then {
		multiple_file_completion "."
	}

	# only show files
	elif [ "${COMP_WORDS[COMP_CWORD -1]}" == "onlyf" ]; then
		standard_file_completion "." "all"



#======TESTING======#
		
	elif [ "${COMP_WORDS[1]}" == "rd" ]; then
		files=()
		COMPREPLY=()
		count=1
		#for file in $(find . -maxdepth 1 -type f -printf "%T@ %p\n" | sort -nr | cut -d' ' -f2-); do
		#	COMPREPLY+=("$count ${file#./}")
		#	count=$((count + 1))
		#done
		
		x=$(find "$1" -maxdepth 1 "${filetype[@]}" -print0 | xargs -0 -I {} basename "{}" | sed 's/ /\\\ /g')
	


	else

#	====== Problems: we have the whitespaces working but for the argments to work we need to custom put in the backslashes, we have to fix this in this process before we press enter running the script
#	======	
		
		files=$(find . -maxdepth 1 -type f -print0 | xargs -0 -I {} basename "{}" | sed 's/ /\\\ /g')	
		custom_commands=("time lset ldir vim okular xournal thunar d cd -mv h l xournal- okular-")

		all_commands="$custom_commands $files"

		mapfile -t COMPREPLY < <(compgen -W "$all_commands" -- "${COMP_WORDS[COMP_CWORD]}")
		

	fi
		
}


complete -F default_completion school










