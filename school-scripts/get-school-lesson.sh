#!/bin/bash

# Function to get current lesson based on time
# Leo Martin (2024)


### VARIABLES ###

# "lesson_directory", "lesson_name", "last_visited_subfolder_variable_name"
geschichte=("/home/leomartin/documents/school/geschichte" "Geschichte" "geschichte_dir")
informatik=("/home/leomartin/documents/school/informatik" "Informatik" "informatik_dir")
deutsch=("/home/leomartin/documents/school/deutsch" "Deutsch" "deutsch_dir")
francais=("/home/leomartin/documents/school/francais" "Francais" "francais_dir")
english=("/home/leomartin/documents/school/english" "English" "english_dir")
physik=("/home/leomartin/documents/school/physik" "Physik" "physik_dir")

physik_praktikum=("/home/leomartin/documents/school/physik-praktikum/fluid-simulation-projekt/" "Physik Praktikum" "physik_praktikum_dir")
wirtschaft=("/home/leomartin/documents/school/wirtschaft" "EWR" "wirtschaft_dir")
mathematik=("/home/leomartin/documents/school/mathematik" "Mathematik" "mathematik_dir")
no_lesson=("/home/leomartin" "No Lesson")
weekend=("/home/leomartin" "Weekend")

testing=("/home/leomartin/documents/school/testing" "Testing" "testing_dir")
 
maturaarbeit=("/home/leomartin/documents/maturaarbeit/" "Maturaarbeit" "maturaarbeit_dir")
projects=("/home/leomartin/documents/projects/" "Projects" "projects_dir")


### FUNCTIONS ###

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

day_of_week=$(date +%u)

function get_current_lesson {

case $day_of_week in

	1) # Monday
		if is_between   07 45 08 30; then lesson_array=("${francais[@]}");
		elif is_between 08 40 09 25; then lesson_array=("${mathematik[@]}");
		elif is_between 09 35 10 20; then lesson_array=("${deutsch[@]}");
		elif is_between 10 35 11 20; then lesson_array=("${physik[@]}");
		elif is_between 11 30 12 15; then lesson_array=("${english[@]}");
		elif is_between 14 15 15 00; then lesson_array=("${informatik[@]}");
		elif is_between 15 10 15 55; then lesson_array=("${informatik[@]}");
		
		else lesson_array=("${no_lesson[@]}"); fi
		;;
	
		
	2) # Tuesday
		if is_between   07 45 08 30; then lesson_array=("${wirtschaft[@]}");
		elif is_between 08 40 09 25; then lesson_array=("${mathematik[@]}");
		elif is_between 09 35 10 20; then lesson_array=("${mathematik[@]}");
		elif is_between 09 35 11 20; then lesson_array=("${deutsch[@]}");
		elif is_between 11 30 12 15; then lesson_array=("${informatik[@]}");
		
		else lesson_array=("${no_lesson[@]}"); fi
		;;
		

	3) # Wednesday
		if is_between   09 35 10 20; then lesson_array=("${physik[@]}");
		elif is_between 10 35 11 20; then lesson_array=("${physik_praktikum[@]}");
		elif is_between 11 30 12 15; then lesson_array=("${physik_praktikum[@]}");
		elif is_between 13 20 14 05; then lesson_array=("${deutsch[@]}");
		elif is_between 14 15 15 00; then lesson_array=("${deutsch[@]}");
		elif is_between 15 10 15 55; then lesson_array=("${geschichte[@]}");
		
		else lesson_array=("${no_lesson[@]}"); fi
		;;


	4) # Thursday
		if is_between   07 45 08 30; then lesson_array=("${geschichte[@]}");
		elif is_between 08 40 09 25; then lesson_array=("${geschichte[@]}");
		elif is_between 09 35 10 20; then lesson_array=("${francais[@]}");
		elif is_between 10 35 11 20; then lesson_array=("${francais[@]}");
		elif is_between 11 30 12 15; then lesson_array=("${physik[@]}");
		elif is_between 13 20 14 05; then lesson_array=("${enlish[@]}");
		elif is_between 14 15 15 00; then lesson_array=("${mathematik[@]}");
					
		else lesson_array=("${no_lesson[@]}"); fi
		;;


	5) # Friday
		if is_between   08 40 09 25; then lesson_array=("${francais[@]}");
		elif is_between 09 35 10 20; then lesson_array=("${mathematik[@]}");
		elif is_between 10 35 11 20; then lesson_array=("${mathematik[@]}");
		elif is_between 11 30 12 15; then lesson_array=("${english[@]}");
				
		else lesson_array=("${no_lesson[@]}"); fi
		;;

	*) # Weekend
		lesson_array=("${weekend[@]}")	
		;;
	
esac

}


