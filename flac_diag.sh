#!/bin/bash
# author: cgomesu
# flac cli doc: https://xiph.org/flac/documentation_tools_flac.html

cleanup () {
	# remove cache file
	if [[ -f $CACHE ]]; then
		rm -f $CACHE
	fi
}

check_requisites () {
	REQUISITES=('flac' 'metaflac' 'echo' 'mkdir' 'date' 'cat' 'find' 'touch' 'grep' 'tr' 'rm')
	for package in ${REQUISITES[@]}; do
		if [[ -z $(command -v $package) ]]; then
			echo 'The following program is not installed or cannot be found in this users $PATH: '$package
			echo 'Fix it and try again.'
			end "Missing packages. Cannot continue." 1
		fi
	done
}

# message then status
end () {
	cleanup
	echo '################################################'
	echo 'END OF THE SCRIPT'
	echo 'MESSAGE: '$1 
	echo '################################################'
	exit $2
}

interrupt () {
	echo '!! ATTENTION !!'
	echo 'Received a signal to stop the script right now.'
	cleanup
	echo '############################################'
	echo '##### THE SCRIPT REACHED A CLEAN STOP. #####'
	echo '############################################'
	exit 1
}

prepare_test_flac () {
	echo 'Preparing files and folders to test flac files...'
	DIR="$1"
	if [[ -z $DIR || ! -d $DIR ]]; then
		echo 'No directory was provided or the argument is not a directory.'
		end "Please provide the full path to a directory when running this script." 1
	fi
	# prepare log folders and files
	LOG_FOLDER='./log/'
	if [[ ! -d $LOG_FOLDER ]]; then
		echo '---------------'
		echo $LOG_FOLDER 'is missing. Creating one...'
		mkdir $LOG_FOLDER
	    echo 'Done.'
	    echo '---------------'
	fi
	GOOD_LOG=$LOG_FOLDER'good_flacs.log'
	if [[ ! -f $GOOD_LOG ]]; then
		echo '---------------'
		echo $GOOD_LOG 'is missing. Creating one...'
	    touch $GOOD_LOG
	    echo 'Done.'
	    echo '---------------'
	fi
	BAD_LOG=$LOG_FOLDER'bad_flacs.log'
	if [[ ! -f $BAD_LOG ]]; then
		echo '---------------'
		echo $BAD_LOG 'is missing. Creating one...' 
	    touch $BAD_LOG
	    echo 'Done.'
	    echo '---------------'
	fi
	CACHE_ERRORS=$LOG_FOLDER'errors/'
	if [[ ! -d $CACHE_ERRORS ]]; then
		echo '---------------'
		echo $CACHE_ERRORS 'is missing. Creating one...'
		mkdir $CACHE_ERRORS
	    echo 'Done.'
	    echo '---------------'
	fi
	# cache in memory
	CACHE=/tmp/flac_diag.cache
	if [[ ! -f $CACHE ]]; then
		echo '---------------'
		echo $CACHE 'is missing. Creating one...' 
	    touch $CACHE
	    echo 'Done.'
	    echo '---------------'
	fi
	# regex patterns
	REGEX_FLAC_VERSION='[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}'
	REGEX_FILENAME='[^\/]+$'
	# flac version into lazy integer
	FLAC_VERSION=$(flac --version | grep -oE $REGEX_FLAC_VERSION | tr -dc '0-9')
}

run_test_flac () {
	echo 'Starting test...'
	# find flac files recursively and do something with them (one at a time)
	find "$DIR" -iname '*.flac' -print0 | while read -d $'\0' file; do
		# skip files that have been analyzed before
		if [[ $(cat $GOOD_LOG | grep -F "$file") ]]; then
			echo '---------------'
			echo 'Skipping' $file
			echo 'This file has already been processed before and it was GOOD then.'
			echo '---------------'
			continue
		elif [[ $(cat $BAD_LOG | grep -F "$file") ]]; then
			echo '---------------'
			echo 'Skipping' $file
			echo 'This file has already been processed before and it was BAD then.'
			echo '---------------'
			continue
		# check file that is not accessible anymore
		elif [[ ! -f $file ]]; then
			echo '---------------'
			echo 'Skipping' $file
			echo 'This is awkward because the file does not seem to exist anymore.'
			if [[ ! -d $DIR ]]; then
				echo 'It looks like the folder' $DIR 'has been removed/unmounted.'
				echo 'No point in continuing.'
				echo '---------------'
				end "Cannot read files anymore" 1
			else
				echo 'The folder' $DIR 'looks accessible. If there are mounts in this folder, you might have lost connection to them.'
			fi
			echo 'Will skip this file but will try the next one anyway.'
			echo '---------------'
			continue
		fi
		# process file
		echo '---------------'
		echo 'Processing file:' $file
		echo 'Date and time:' $(date)
		flac -st "$file" > $CACHE 2>&1
		FLAC=$(cat $CACHE)
		if [[  $FLAC  ]]; then
			# catch errors due to file not being accessible anymore
			if [[ -f $file ]]; then
				echo 'Uh-oh! THE FLAC FILE HAS AN ERROR!'
				FILE_FLAC_VERSION=$(metaflac --show-vendor-tag "$file" 2>&1 | grep -oE $REGEX_FLAC_VERSION | tr -dc '0-9')
				if [[ -z $FILE_FLAC_VERSION ]]; then
					echo 'I am unable to retrieve the flac version from the file.'
				elif [[ $FLAC_VERSION < $FILE_FLAC_VERSION ]]; then
					echo 'You are possibly using an OUTDATED FLAC VERSION.'
					echo 'Try to update your flac and run this script again after cleaning' $BAD_LOG '.'
				elif [[ $FLAC_VERSION >= $FILE_FLAC_VERSION ]]; then
					echo 'The audio file is LIKELY CORRUPTED.'
				fi
				echo 'The file will be added to' $BAD_LOG
				echo $file >> $BAD_LOG
				echo 'To investigate the error, check' $CACHE_ERRORS
				FILENAME=$(echo $file | grep -oE $REGEX_FILENAME)
				ERROR_FILE=$CACHE_ERRORS$FILENAME'.err'
				cat $CACHE > "$ERROR_FILE"
			else
				echo 'This file is NO LONGER AVAILABLE.'
				echo 'Will try the next one.'
				continue
			fi
		else
			echo 'Good news, everyone! THE FLAC FILE IS OKAY!'
			echo 'The file will be added to' $GOOD_LOG
			echo $file >> $GOOD_LOG
		fi
		echo '---------------'
	done
}

start () {
	echo '################################################'
	echo '############# FLAC DIAGNOSTIC TOOL #############'
	echo '################################################'
	echo 'This script tests FLAC audio files recursively '
	echo 'and generates logs with good files (no errors '
	echo 'found) and bad ones (at least one error found). '
	echo 'It tests .flac files with the help of the flac '
	echo 'command line utility.'
	echo 'For more info, check the repo:'
	echo 'https://github.com/cgomesu/bash-flac-diag'
	echo '################################################'
}

# run the script
start
check_requisites
prepare_test_flac "$1"
trap 'interrupt' SIGINT SIGHUP SIGTERM SIGKILL
run_test_flac
if [[ $? = 0 ]]; then
	end "The script finished without errors." 0
fi
