#!/bin/bash

# Script to open files in various programms in the terminal
# Leo Martin (2025)


### VARIABLES ###
source "$HOME/.scripts/get-school-lesson.sh"
source "$HOME/.scripts/config.sh"
source "$HOME/.scripts/functions.sh"


# get current lesson so that directory autocomplete works
[ -s "$lesson_log_file" ] && {
    lesson_name="$(cat "$lesson_log_file")"
    declare -n ref_array="$lesson_name"
    lesson_array=("${ref_array[@]}")
} || {
    get_current_lesson
}



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

function school {

# get current lesson array
[ -s "$lesson_log_file" ] && { # if lesson log file is not empty
    lesson_name="$(cat "$lesson_log_file")"
    declare -n ref_array="$lesson_name"
    lesson_array=("${ref_array[@]}")
} || {
    get_current_lesson
}


### FUNCTIONALITIES ###

# cd into last visited subfolder
[ "$#" -eq 0 ] && {
    [ "${lesson_array[1]}" == "No Lesson" ] && { echo "No Lesson currently!"; return; }

	last_visited_dir="$(get_last_dir)"
		
	[ -d "${lesson_array[0]}/$last_visited_dir" ] && {
		source "$cd_script_dir" "${lesson_array[0]}/$last_visited_dir"
	} || {
		source "$cd_script_dir" "${lesson_array[0]}" # if directory does not exist go to base folder
	}
}

# cd into home directory
[ "$1" == "." ] && {
	source "$cd_script_dir" "${lesson_array[0]}"
}

# cd into the download folder
[ "$1" == "d" ] && {
	source "$cd_script_dir" "$download_dir"
}

# display manual for shell script
[ "$1" == "-h" ] || [ "$1" == "--help" ] && {
	cat "$help_file"
}

# display the current lesson
[ "$1" == "l" ] && {
	echo "Current Lesson: $(tput bold; tput setaf 11)${lesson_array[1]}"
}

# set last visited directory
[ "$1" == "ldir" ] && {
    [ "$#" -ge 2 ] && { # if there are more than two arguments, set the directory
		chosen_dir="" 
		for arg in "${@:2}"; do # combine all the folders to one directory
			[ -z "$chosen_dir" ] && {
				chosen_dir="$arg"
			} || {
				chosen_dir="$chosen_dir$arg"
			}
		done
		
		[ -d "${lesson_array[0]}/$chosen_dir" ] || { # if dir does not exist, create it
			mkdir -p "${lesson_array[0]}/$chosen_dir"
		    echo "Directory created: $(tput bold; tput setaf 13)$chosen_dir/"
		}

		write_last_dir "$chosen_dir"

		echo "$(tput sgr0)Last visited subfolder:$(tput bold; tput setaf 13) $chosen_dir"
		source "$cd_script_dir" "${lesson_array[0]}/$chosen_dir"
    } || { # if only one argument is given, echo the last visited directory
		last_visited_dir=$(get_last_dir)
		echo "Last visited subfolder: $(tput bold; tput setaf 13)$last_visited_dir"
    }
}

# overwrite current lesson
[ "$1" == "lset" ] && {
    [ "$#" -ge 2 ] && {
		echo "$2" > "$set_lesson_log_file"
		echo "Current Lesson: $(tput bold; tput setaf 11)$2"
    } || { 
		> "$set_lesson_log_file" # set lesson to default
		echo "Current Lesson reset"
    }
}

# open thunar file manager
[ "$1" == "thunar" ] && {
    [ "$#" -ge 2 ] && { # open in last base directory
		source "$cd_script_dir" "${lesson_array[0]}"
		thunar "${lesson_array[0]}"
    } || { # open in last dir
		last_visited_dir=$(get_last_dir)
		source "$cd_script_dir" "${lesson_array[0]}/$last_visited_dir"
		thunar "${lesson_array[0]}/$last_visited_dir"
    }
}

# cd into a chosen subfolder
[ "$1" == "cd" ] && {
    chosen_dir="" 
    for arg in "${@:2}"; do # combine all the folders to one directory
		[ -z "$chosen_dir" ] && {
		    chosen_dir="$arg"
	    } || {
    	    chosen_dir="$chosen_dir/$arg"
	    }
	done
		
    [ -d "${lesson_array[0]}/$chosen_dir" ] || { # if dir does not exist, create it
		mkdir -p "${lesson_array[0]}/$chosen_dir"
        echo "Directory created: $(tput bold; tput setaf 13)$chosen_dir"
    }

	source "$cd_script_dir" "${lesson_array[0]}/$chosen_dir"
}

### PROGRAMMS ###
# open or create txt file in neovim in chosen directory
[ "$1" == "vim" ] && {
    chosen_dir="" 
    for arg in "${@:2:$#-2}"; do # combine all the folders to one directory
		[ -z "$chosen_dir" ] && {
		    chosen_dir="$arg"
	    } || {
    	    chosen_dir="$chosen_dir$arg"
	    }
	done
    
	[ -d "${lesson_array[0]}/$chosen_dir" ] || { # if dir does not exist, create it
		mkdir -p "${lesson_array[0]}/$chosen_dir"
        echo "Directory created: $(tput bold; tput setaf 13)$chosen_dir"
    }

	source "$cd_script_dir" "${lesson_array[0]}/$chosen_dir"

	[ -f "${@: -1}" ] && {
		nvim "${@: -1}" 
	} || {
    	nvim "${@: -1}.txt" # create .txt file if inputed does not exist
	}
}

# open file in chosen subfolder of current lesson in okular
[ "$1" == "okular" ] && {
    chosen_dir="" 
    for arg in "${@:2:$#-2}"; do # combine all the folders to one directory
		[ -z "$chosen_dir" ] && {
		    chosen_dir="$arg"
	    } || {
    	    chosen_dir="$chosen_dir$arg"
	    }
	done

	source "$cd_script_dir" "${lesson_array[0]}/$chosen_dir"
	[ -f "${@: -1}" ] && {
			okular "${@: -1}"
	}
}

# open files in xournal
[ "$1" == "xournal" ] && {
    chosen_dir="" 
    for arg in "${@:2:$#-2}"; do # combine all the folders to one directory
		[ -z "$chosen_dir" ] && {
		    chosen_dir="$arg"
	    } || {
    	    chosen_dir="$chosen_dir$arg"
	    }
	done

	source "$cd_script_dir" "${lesson_array[0]}/$chosen_dir"
	[ -f "${@: -1}" ] && {
			xournalpp "${@: -1}"
	}
}

[ "$1" == "chat" ] && {
    $DEFAULT_BROWSER "https://chatgpt.com/"
}

[ "$1" == "teams" ] && {
		echo "g"
}

}


### DIFFERENT AUTO COMPLETES ### 

# auto complete subfolders in a directory, $1=directory
function standard_subfolder_completion {
	available_subfolders=$(ls -d "$1"/*/ 2>/dev/null)
	[ -n "$available_subfolders" ] && {
		available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename | sed 's/$/\//') 
	} 
	COMPREPLY=($(compgen -W "$available_subfolders" -- "${COMP_WORDS[COMP_CWORD]}"))	
}


# auto complete all files and folders in a directory, $1=lesson-directory / $2=filetype
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
    for remove_file in $COMP_LINE; do # remove files that are already chosen
		files=$(echo "$files" | grep -v "^$remove_file$")
	done

    available_subfolders=$(ls -d "$1"/*/ 2>/dev/null)
    [ -n "$available_subfolders" ] && {
		available_subfolders=$(echo "$available_subfolders" | xargs -n 1 basename | sed 's/$/\//')
    }

	files_and_folders="$files $available_subfolders"

    # mapfile to correctly display filenames with spaces
	mapfile -t COMPREPLY < <(compgen -W "$files_and_folders" -- "${COMP_WORDS[COMP_CWORD]}") 

}


function default_completion {
	# if no argument written, only show files and not custom commands
	if [ -z "${COMP_WORDS[1]}" ]; then
		standard_file_completion "." "all"

    # ldir
    elif [ "${COMP_WORDS[1]}" == "ldir" ]; then
		local base_dir="${lesson_array[0]}"
		local current_path="$base_dir"
		# Build the relative path from arguments starting at index 2
		for (( i=2; i<COMP_CWORD; i++ )); do # simplify if possible
		    current_path="${current_path}/${COMP_WORDS[i]}"
		done
		standard_subfolder_completion "$current_path"

    # lset
	elif [ "${COMP_WORDS[1]}" == "lset" ]; then
		[ "$COMP_CWORD" -gt 2 ] && {
			COMPREPLY=() # this command cannot have more than one arguments
		} || {	
		    available_lessons=$(ls -d "$main_base_dir"/*/ 2>/dev/null)
		    [ -n "$available_lessons" ] && {
				available_lessons=$(echo "$available_lessons" | xargs -n 1 basename) 
		    }
			COMPREPLY=($(compgen -W "$available_lessons" -- "${COMP_WORDS[COMP_CWORD]}"))
		}
		
    # cd
    elif [ "${COMP_WORDS[1]}" == "cd" ]; then
		local base_dir="${lesson_array[0]}"
		local current_path="$base_dir"
		# Build the relative path from arguments starting at index 2
		for (( i=2; i<COMP_CWORD; i++ )); do # simplify if possible
		    current_path="${current_path}/${COMP_WORDS[i]}"
		done
		standard_subfolder_completion "$current_path"

    # vim
    elif [ "${COMP_WORDS[1]}" == "vim" ]; then
		local base_dir="${lesson_array[0]}"
		local current_path="$base_dir"

		# Build the current path by joining all arguments from index 2 up to COMP_CWORD (the one being completed)
		for (( i=2; i<COMP_CWORD; i++ )); do
            current_path="${current_path}/${COMP_WORDS[i]}"
		done

		standard_file_completion "$current_path" "txt"
		
    # okular
    elif [ "${COMP_WORDS[1]}" == "okular" ]; then
		local base_dir="${lesson_array[0]}"
		local current_path="$base_dir"

		# Build the current path by joining all arguments from index 2 up to COMP_CWORD (the one being completed)
		for (( i=2; i<COMP_CWORD; i++ )); do
            current_path="${current_path}/${COMP_WORDS[i]}"
		done

		standard_file_completion "$current_path" "pdf"

    # xournal
    elif [ "${COMP_WORDS[1]}" == "xournal" ]; then
		local base_dir="${lesson_array[0]}"
		local current_path="$base_dir"

		# Build the current path by joining all arguments from index 2 up to COMP_CWORD (the one being completed)
		for (( i=2; i<COMP_CWORD; i++ )); do
            current_path="${current_path}/${COMP_WORDS[i]}"
		done

		standard_file_completion "$current_path" "pdf_xopp"	

    # ...
	else
		files=$(find . -maxdepth 1 -type f -print0 | xargs -0 -I {} basename "{}" | sed 's/ /\\\ /g')	
		custom_commands=("lset ldir vim okular xournal thunar chat d cd -mv l")
		combined="$custom_commands $files" # add the script commands and files 

		mapfile -t COMPREPLY < <(compgen -W "$combined" -- "${COMP_WORDS[COMP_CWORD]}")
		
	fi
		
}


complete -F default_completion school



