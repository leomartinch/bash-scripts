#!/bin/bash
# Script to quit DWM
# Leo Martin (2025)

choice=$(echo -e "shutdown\nreboot" | dmenu -noi -p "Shut Down " -pb "#710000")

case $choice in
		shutdown) 
				confirmation=$(echo -e "no\nyes" | dmenu -noi -p "Are you sure?")
				case $confirmation in
						no)
								exit
								;;
						yes)
								pkill xinit
								;;
						*)
								exit
						;;
				esac
				;;

		reboot) 
				confirmation=$(echo -e "no\nyes" | dmenu -l 5 -p "Are you sure?")
				[ "$confirmation" == "no" ] && {
						exit
				} || {
						sudo reboot 
				}
				;;

		*) ;;

esac
