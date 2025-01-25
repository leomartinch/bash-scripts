#!/bin/bash

day_of_week=$(date +%u)


# what does the programm do:
# - cd into the directory of the current lession (school)
# - when given two files as argument, it will move the file to the folder of the current lession and the second argument is how the file will be renamed (school file1 file2)
# - it can show how long the lession still takes
# - 



# Features to add
# - choose which subfolder in the lession directory you save something
# - when cd into a directory show the subdirectories, if not tab into any you go to the default
# - if we write a subdirectory that doesnt exist, then create it
# - a function that can create a merged pdf with all the pdfs inside a folder
#
#
# Bugs to fix
# - the custom completion works but it does not replace spaces with \ so it wont work after you press enter
# - make sub sub directories to be the ldir
# - problems with commands being not wrapped correctly (it has to do with the st terminal)
# - 



# Lession Arrays
# "lession directory" "Lession Name" "last visited subfolder variable name"

geschichte=("/home/leomartin/documents/school/geschichte" "Geschichte" "geschichte_dir")
informatik=("/home/leomartin/documents/school/informatik" "Informatik" "informatik_dir")
deutsch=("/home/leomartin/documents/school/deutsch" "Deutsch" "deutsch_dir")
francais=("/home/leomartin/documents/school/francais" "Francais" "francais_dir")
english=("/home/leomartin/documents/school/english" "English" "english_dir")
physik=("/home/leomartin/documents/school/physik" "Physik" "physik_dir")
physik_praktikum=("/home/leomartin/documents/school/physik/praktikum" "Physik Praktikum" "physik_praktikum_dir")
wirtschaft=("/home/leomartin/documents/school/wirtschaft" "EWR" "wirtschaft_dir")
mathematik=("/home/leomartin/documents/school/mathematik" "Mathematik" "mathematik_dir")

no_lesson=("/home/leomartin" "No Lesson")
weekend=("/home/leomartin" "Weekend")


# variables
cd_script_dir="/home/leomartin/.scripts/school-cd-script.sh"
last_visited_dir_file="/home/leomartin/.scripts/.last_visited_dir"
set_lesson_log_file="/home/leomartin/.scripts/.set_lesson.log"
download_dir="/home/leomartin/downloads"
help_file="/home/leomartin/.scripts/school-script-instructions.txt"


testing=("/home/leomartin/documents/school/testing" "Testing" "testing_dir")
 


is_between() {
	current_hour=$(date +%H)
	current_minute=$(date +%M)
	
	local start_hour=$1
	local start_minute=$2
	local end_hour=$3
	local end_minute=$4

	local current_total_minutes=$((10#$current_hour * 60 + 10#$current_minute))
	local start_total_minutes=$((10#$start_hour * 60 + 10#$start_minute))
	local end_total_minutes=$((10#$end_hour * 60 + 10#$end_minute))

	time_in_lesson=$(($current_total_minutes - $start_total_minutes))
	
	[ "$current_total_minutes" -ge "$start_total_minutes" ] && [ "$current_total_minutes" -lt "$end_total_minutes" ]
	
}


function get_current_lession {

case $day_of_week in

	1) # Monday
		if is_between   08 40 09 25; then lesson_array=("${physik_praktikum[@]}");
		elif is_between 09 35 10 20; then lesson_array=("${physik_praktikum[@]}");
		elif is_between 10 35 11 20; then lesson_array=("${mathematik[@]}");
		elif is_between 11 30 12 15; then lesson_array=("${mathematik[@]}");
		elif is_between 13 20 14 05; then lesson_array=("${geschichte[@]}");
		elif is_between 14 15 15 00; then lesson_array=("${informatik[@]}");
		elif is_between 15 10 15 55; then lesson_array=("${informatik[@]}");
		
		else lesson_array=("${no_lesson[@]}"); fi
		;;
	
		
	2) # Tuesday
		if is_between   07 45 08 30; then lesson_array=("${english[@]}");
		elif is_between 08 40 09 25; then lesson_array=("${francais[@]}");
		elif is_between 09 35 10 20; then lesson_array=("${physik[@]}");
		elif is_between 09 35 11 20; then lesson_array=("${mathematik[@]}");
		elif is_between 11 30 12 15; then lesson_array=("${informatik[@]}");
		
		else lesson_array=("${no_lesson[@]}"); fi
		;;
		

	3) # Wednesday
		if is_between   13 20 14 05; then lesson_array=("${deutsch[@]}");
		elif is_between 14 15 15 00; then lesson_array=("${deutsch[@]}");
		elif is_between 15 10 15 55; then lesson_array=("${geschichte[@]}");
		
		else lesson_array=("${no_lesson[@]}"); fi
		;;


	4) # Thursday
		if is_between   07 45 08 30; then lesson_array=("${geschichte[@]}");
		elif is_between 08 40 09 25; then lesson_array=("${francais[@]}");
		elif is_between 09 35 10 20; then lesson_array=("${francais[@]}");
		elif is_between 10 35 11 20; then lesson_array=("${english[@]}");
		elif is_between 11 30 12 15; then lesson_array=("${deutsch[@]}");
		elif is_between 13 20 14 05; then lesson_array=("${mathematik[@]}");
		elif is_between 14 15 15 00; then lesson_array=("${mathematik[@]}");
		elif is_between 15 10 15 55; then lesson_array=("${wirtschaft[@]}");

		elif is_between 15 10 22 55; then lesson_array=("${geschichte[@]}");
			
		else lesson_array=("${no_lesson[@]}"); fi
		;;


	5) # Friday
		if is_between   08 40 09 25; then lesson_array=("${physik[@]}");
		elif is_between 09 35 10 20; then lesson_array=("${mathematik[@]}");
		elif is_between 10 35 11 20; then lesson_array=("${mathematik[@]}");
		elif is_between 13 20 14 05; then lesson_array=("${wirtschaft[@]}");
		elif is_between 14 15 15 00; then lesson_array=("${english[@]}");
		elif is_between 15 10 15 55; then lesson_array=("${deutsch[@]}");
		
		else lesson_array=("${no_lesson[@]}"); fi
		;;

	*) # Weekend
		lesson_array=("${weekend[@]}")	
		;;
	
esac

}

# if log file is not empty overwrite the get_current_lession
#[ -s $set_lession_log_file ] && { # if set_lession log file is not empty
#	lession_name="$(cat $set_lession_log_file)"
#	declare -n ref_array="$lession_name"
#	lession_array=("${ref_array[@]}")
#
#} || { # if set_lession log file is empty
#	get_current_lession
#}

#lession_array=("oko" "ligma")









### FUNCTIONS

function get_last_dir {
	last_visited_dir=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
	echo "$last_visited_dir"
}

function write_last_dir {
	dir_variable_name="${lesson_array[2]}"
	grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s|^$dir_variable_name=.*|$dir_variable_name=$1|" "$last_visited_dir_file" 


}





function school {

[ -s $set_lesson_log_file ] && { # if set_lesson log file is not empty
	lesson_name="$(cat $set_lesson_log_file)"
	declare -n ref_array="$lesson_name"
	lesson_array=("${ref_array[@]}")

} || { # if set_lesson log file is empty
	get_current_lesson
}

#last_visited_dir=$(grep "^${lession_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
#last_visited_dir=$(get_last_dir)




#new_args=()


#for argument in "$@"; do
#	[ "$argument" != "sort-" ] && {
#		new_args+=("$argument")
#	} 
#done



#argument_count=${#new_args[@]}


case $# in
	0)
		# cd into last visited subfolder, if last visited subfolder not exist 
		[ "${lesson_array[1]}" == "No Lesson" ] && { echo "No Lesson currently!"; return; }

		last_visited_dir=$(grep "^${lesson_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
		
		[ -d "${lesson_array[0]}/$last_visited_dir" ] && {
			source "$cd_script_dir" "${lesson_array[0]}/$last_visited_dir"
		} || {
			#dir_variable_name="${lession_array[2]}"
			#grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s/^$dir_variable_name=.*/$dir_variable_name=/" "$last_visited_dir_file" 
			write_last_dir "/"
			source "$cd_script_dir" "${lesson_array[0]}"
		}
		;;


	1)
		#tput setaf 9
		[ -f "$1" ] && {
			tput bold
			tput setab 9
			echo "one file"
			tput sgr0
		}

		
		# cd into home directory
		[ "$1" == "." ] && {
			source "$cd_script_dir" "${lession_array[0]}"
		}
		
		# cd into the download folder (update in the help file)
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
			source "$cd_script_dir" "${lesson_array[0]}/$last_visited_dir"
			thunar "${lesson_array[0]}/$last_visited_dir"
		}

		# display how much time is left in the current lession
		[ "$1" == "time" ] && {			
			[ "${lesson_array[1]}" == "No Lesson" ] || [ "${lession_array[1]}" == "Weekend" ] || [ -s "$set_lesson_log_file" ] && {
			#[ "${lession_array[1]}" == "No Lession" ] || [ "${lession_array[1]}" == "Weekend" ] && { 
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

		# display the current lession
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
			[ -d "${lession_array[0]}/$2" ] || {
				mkdir "${lession_array[0]}/$2"
				echo "Directory created: $(tput bold; tput setaf 13)$2/"
			}

			write_last_dir "$2"

			echo "$(tput sgr0)Last visited subfolder:$(tput bold; tput setaf 13) $2/"
			source "$cd_script_dir" "${lession_array[0]}/$2"

		}

		# set current lession and overwrite get_current_lession script
		[ "$1" == "lset" ] && {
			echo "$2" > "$set_lession_log_file"
			echo "Current Lession: $(tput bold; tput setaf 11)$2"
		}

		# cd into a chosen subfolder
		[ "$1" == "cd" ] && {
			source "$cd_script_dir" "${lession_array[0]}/$2"
		}

		# open file in neovim in last visited subfolder of current directory
		[ "$1" == "vim" ] && {
			source "$cd_script_dir" "${lession_array[0]}/$last_visited_dir"
			[ -f "$2" ] && {
				nvim "$2"
			} || {
				nvim "$2.txt"
			}
		}

		# open thunar in the current lession directory
		[ "$1" == "thunar" ] && [ "$2" == "." ] && {
			source "$cd_script_dir" "${lession_array[0]}"
			thunar "${lession_array[0]}"
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
		
			#last_visited_dir=$(grep "^${lession_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			last_visited_dir=$(get_last_dir)
			mv "$1" "${lession_array[0]}/$last_visited_dir/$filename_with_extension"

			source "$cd_script_dir" "${lession_array[0]}/$last_visited_dir"
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

			[ -d "${lession_array[0]}/$3" ] || {
				mkdir "${lession_array[0]}/$3"
				echo "Folder created: $(tput bold; tput setaf 13)$3/"
			}

			mv "$1" "${lession_array[0]}/$3/$filename_with_extension"	
			source "$cd_script_dir" "${lession_array[0]}/$3"

			#dir_variable_name="${lession_array[2]}"
			#grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s/^$dir_variable_name=.*/$dir_variable_name=$3/" "$last_visited_dir_file"
			write_last_dir "$3"

			tput sgr0
	
		}




		# cd into a chosen sub-subfolder
		[ "$1" == "cd" ] && {
			[ -d "${lession_array[0]}/$2/$3" ] && {
    				source "$cd_script_dir" "${lession_array[0]}/$2/$3"
			} || {
				echo "Error: Subfolder does not exist!"
			}
		}

		# open or create txt file in neovim in chosen directory
		[ "$1" == "vim" ] && {
			[ "$2" == "-" ] && {
				subfolder=$(grep "^${lession_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			} || {	
				subfolder="$2"
			}
			source "$cd_script_dir" "${lession_array[0]}/$subfolder"

			[ -f "$3" ] && {
				nvim "$3"
			} || {
				nvim "$3.txt"
			}
		}


		
		# open file in chosen subfolder of current lession in okular
		[ "$1" == "okular" ] && {
			[ "$2" == "-" ] && {
				folder=$(grep "^${lession_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			} || {
				folder="$2"
			}
			source "$cd_script_dir" "${lession_array[0]}/$folder"
			okular "${lession_array[0]}/$folder/$3"
		}

		# open file in chosen subfolder of current lession in xournal
		[ "$1" == "xournal" ] && {
			[ "$2" == "-" ] && {
				folder=$(grep "^${lession_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			} || {
				folder="$2"
			}
			source "$cd_script_dir" "${lession_array[0]}/$folder"
			xournalpp "${lession_array[0]}/$folder/$3"
		}


		# move and rename file to last used subfolder of current lession and then open in okular or xournal
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

			#last_visited_dir=$(grep "^${lession_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			last_visited_dir=$(get_last_dir)
			mv "$2" "${lession_array[0]}/$last_visited_dir/$filename_with_extension"


			source "$cd_script_dir" "${lession_array[0]}/$last_visited_dir"

			[ "$1" == "okular-" ] && {
				okular "$filename_with_extension"
			} || { 
				xournalpp "$filename_with_extension"
			}
		}

		# EXPERIMENTAL: could break other commands
		# change last visited sub subfolder 
		[ "$1" == "ldir" ] && {
			[ -d "${lession_array[0]}/$2/$3" ] || {
				mkdir "${lession_array[0]}/$2/$3"
				echo "Directory created: $(tput bold; tput setaf 13)$3/"
			}

			sub_sub_dir="$2/$3"

			dir_variable_name="${lession_array[2]}"
			grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s|^$dir_variable_name=.*|$dir_variable_name=$sub_sub_dir|" "$last_visited_dir_file"

			echo "$(tput sgr0)Last visited sub-subfolder:$(tput bold; tput setaf 13) $2/$3/"
			source "$cd_script_dir" "${lession_array[0]}/$2/$3"

		}
		;;




	*)
	# move and rename file to chosen subfolder in current lession and then open in okular or xournal
	[ "$1" == "xournal-" ] || [ "$1" == "okular-" ] && [ -f "$2" ] && [ "$3" == "-mv" ] && {
		read -e -p "$(tput bold; tput setaf 9)[Rename] $(tput setaf 11)$2$(tput setaf 15):$(tput sgr0) " new_filename
		subfolder="$4"

		[ -z "$new_filename" ] && { # if pressed enter, dont rename file
			new_filename="${1%.*}"
		}

		original_filename=$(basename -- "$2")
		main_extension="${original_filename##*.}"
		filename_with_extension="$new_filename.$main_extension"

		# needs design improvement
		echo "$(tput bold; tput setaf 10)  =====> $filename_with_extension$(tput setab 0)"

		[ -d "${lession_array[0]}/$subfolder" ] || {
			mkdir "${lession_array[0]}/$subfolder"
			echo "Directory created: $(tput bold; tput setaf 13)$subfolder/"
		}
	
		#dir_variable_name="${lession_array[2]}"
		#grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s/^$dir_variable_name=.*/$dir_variable_name=$subfolder/" "$last_visited_dir_file"
		write_last_dir "$subfolder"

		mv "$2" "${lession_array[0]}/$subfolder/$filename_with_extension"
		source "$cd_script_dir" "${lession_array[0]}/$subfolder"

		[ "$1" == "okular-" ] && {
			okular "$filename_with_extension"
		} || { 
			xournalpp "$filename_with_extension"
		}
	}
		

	# move and rename multiple files to a chosen subfolder or to the last visited subfolder
	[ "${@: -2:1}" == "-mv" ] || [ "${@: -1}" == "-mv" ] && {		
		tput bold
		
		[ "${@: -2:1}" == "-mv" ] && { # if the subfolder is given
			directory_name="${@: -1}"
			#dir_variable_name="${lession_array[2]}"
			#grep -q "^$dir_variable_name=" "$last_visited_dir_file" && sed -i "s/^$dir_variable_name=.*/$dir_variable_name=$directory_name/" "$last_visited_dir_file"
			write_last_dir "$directory_name"
		} || {
			#directory_name=$(grep "^${lession_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
			directory_name=$(get_last_dir)
		}
			
		rename_array=()
		original_array=()
		visual_index=1	
		
		# rename all the files
		echo "$(tput setab 4; tput setaf 15)Rename Files:$(tput setab 0)"
		for current_file in "$@"; do

			[ "$current_file" == "-mv" ] && {
				echo -e "\n$(tput sgr0)Check if everything is correct!"
				break
			}
			
			read -e -p "$(tput setaf 9)[$visual_index] $(tput setaf 11)$current_file$(tput setaf 15):$(tput sgr0) " new_filename
			
			[ -z "$new_filename" ] && { # if pressed enter, dont rename file
				new_filename="${current_file%.*}"
			}

			original_filename=$(basename -- "$current_file")
			main_extension="${original_filename##*.}"
			filename_with_extension="$new_filename.$main_extension"

			rename_array+=("$filename_with_extension")
			original_array+=("$current_file")
			((visual_index++))
	
			echo "$(tput bold; tput setaf 10)=>  $filename_with_extension$(tput setab 0)"
		done
		
		# check if user wants to change a filename, if not press enter
		while true; do
			read -e -p "$(tput sgr0)Type number or press Enter to start: " user_confirmation

			[ -z "$user_confirmation" ] && { # if pressed enter, stop while loop
				echo -e "$(tput bold; tput setaf 9)Moving Files!\n"
				break
			}

			[ "$user_confirmation" == "q" ] && { # if input is [q], quitt script
				echo "$(tput bold; tput setaf 9)Terminated!"
				return
			}

			index=$((user_confirmation - 1))

			read -e -p "$(tput bold; tput setaf 15)Rename$(tput setaf 9) [$((index + 1))]$(tput setaf 11) ${original_array[$index]}$(tput setaf 15):$(tput sgr0) " rename_filename
			
			[ -z "$rename_filename" ] && { # if pressed enter while renaming, dont change name
				echo "$(tput bold; tput setaf 10)       =>  ${rename_array[$index]}"	
				continue
			}
			
			original_filename=$(basename -- "${original_array[$index]}")
			main_extension="${original_filename##*.}"
			rename_array[$index]="$rename_filename.$main_extension"

			echo "$(tput bold; tput setaf 10)       =>  ${rename_array[$index]}"
		done

		# if the user is ok with everything move and rename all the files, if directory does not exist create it
		[ -d "${lession_array[0]}/$directory_name" ] || {
			mkdir "${lession_array[0]}/$directory_name"
			echo "$(tput sgr0)New Directory created: $(tput bold; tput setaf 13)$directory_name/"
		}

		for i in "${!rename_array[@]}"; do
			mv "${original_array[$i]}" "${lession_array[0]}/$directory_name/${rename_array[$i]}"  
		done

		original_path="${lession_array[0]}"
		short_dir_path="${original_path#/home/leomartin/documents/school/}" # remove /home/...
		echo "$(tput sgr0)Files moved to: $(tput bold; tput setaf 13)$short_dir_path/$directory_name/"

		source "$cd_script_dir" "${lession_array[0]}/$directory_name"
		tput sgr0
	}
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
			standard_subfolder_completion "${lession_array[0]}"
		}
		[ "$COMP_CWORD" -eq 3 ] && {
			standard_subfolder_completion "${lession_array[0]}/${COMP_WORDS[2]}"
		}

	# lset
	elif [ "${COMP_WORDS[1]}" == "lset" ]; then
		[ "$COMP_CWORD" -gt 2 ] && {
			COMPREPLY=() # this command cannot have more arguments
		} || {
			available_lessions="geschichte informatik deutsch francais english physik physik_praktikum wirtschaft mathematik"
			COMPREPLY=($(compgen -W "$available_lessions" -- "${COMP_WORDS[COMP_CWORD]}"))
		}
		
	# cd
	elif [ "${COMP_WORDS[1]}" == "cd" ]; then
		[ "$COMP_CWORD" -gt 3 ] && {
			COMPREPLY=() # this command cannot have more arguments
		} || {
			standard_subfolder_completion "${lession_array[0]}"
		}
		[ "$COMP_CWORD" -eq 3 ] && {
			standard_subfolder_completion "${lession_array[0]}/${COMP_WORDS[2]}"
		}

	# -mv
	elif [ "${COMP_WORDS[COMP_CWORD -1]}" == "-mv" ]; then
		standard_subfolder_completion "${lession_array[0]}"

#======= Programms
	# vim
	elif [ "${COMP_WORDS[1]}" == "vim" ]; then # show subfolders, then only show txt files
		[ "$COMP_CWORD" -eq 2 ] && {
			standard_subfolder_completion "${lession_array[0]}"
		}
		[ "$COMP_CWORD" -eq 3 ] && {
			[ "${COMP_WORDS[2]}" == "-" ] && {
				last_visited_subfolder=$(grep "^${lession_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
				standard_file_completion "${lession_array[0]}/$last_visited_subfolder" "txt"
			} || {
				standard_file_completion "${lession_array[0]}/${COMP_WORDS[2]}" "txt"
			}
		}
	
		[ "$COMP_CWORD" -gt 3 ] && {
			COMPREPLY=()
		}

	# open file in xournal, okular
	elif [ "${COMP_WORDS[1]}" == "xournal" ] || [ "${COMP_WORDS[1]}" == "okular" ]; then
		#last_visited_subfolder=$(grep "^${lession_array[2]}=" "$last_visited_dir_file" | cut -d'=' -f2-)
		last_visited_subfolder=$(get_last_dir)

		[ "$COMP_CWORD" -gt 3 ] && {
			COMPREPLY=()
		}
		[ "$COMP_CWORD" -eq 2 ] && {
			standard_subfolder_completion "${lession_array[0]}"
		}

		[ "$COMP_CWORD" -eq 3 ] && [ "${COMP_WORDS[1]}" == "okular" ] && {
			[ "${COMP_WORDS[2]}" == "-" ] && { # if user wants to user last visited subfolder
				standard_file_completion "${lession_array[0]}/$last_visited_subfolder" "pdf"
			} || {	
				standard_file_completion "${lession_array[0]}/${COMP_WORDS[2]}" "pdf"
			}
		}
		[ "$COMP_CWORD" -eq 3 ] && [ "${COMP_WORDS[1]}" == "xournal" ] && {
			[ "${COMP_WORDS[2]}" == "-" ] && { # if user wants to user last visited subfolder
				standard_file_completion "${lession_array[0]}/$last_visited_subfolder" "pdf_xopp"
			} || {	
				standard_file_completion "${lession_array[0]}/${COMP_WORDS[2]}" "pdf_xopp"
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
			standard_subfolder_completion "${lession_array[0]}"
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










