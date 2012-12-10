#!/bin/bash

PYTHON_CURRENT_SCEDULE=./current_course_directory.py
SCHEDULE_FILE=schedule.ini
FOUND_MACS=$(sudo iwlist scan 2> /dev/null | sed -n 's/[ \t]*Cell [0-9]\+ - Address: \(.*\)$/\1/p');
CURRENT_HOUR=$(date | sed 's/^.* \([0-9]\+\):[0-9]\+:[0-9]\+.*/\1/')
LESSON_DIR=$(python $PYTHON_CURRENT_SCEDULE $SCHEDULE_FILE)

SCHOOL_MAC=80:B6:86:8F:C6:E4

for i in $FOUND_MACS; do
    case $i in
	$HOME_MAC )
	    echo "You are at home"
	    killall nautilus;
	    exit;
	    ;;
	$SCHOOL_MAC )
	    if [[ $LESSON_DIR != 'Not found' ]]; then
		echo "Opening folder $LESSON_DIR";
		nautilus $LESSON_DIR;
	    else
		echo "No lesson right now.";
	    fi
	    exit
	    ;;
	* )
	    echo "Not at a known location."
    esac
done
