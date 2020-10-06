#!bash
# author: cgomesu

echo '###############################################'
echo 'STARTING SCRIPT:' $(date)
echo '###############################################'

DIR=$1
GOOD_LOG=./log/good_flacs.log
BAD_LOG=./log/bad_flacs.log
CACHE=./cache
REGEX_VERSION='[0-9]\.[0-9]\.[0-9]'
FLAC_VERSION=$(flac --version | grep -oE $REGEX_VERSION | tr -dc '0-9')
# REGEX_BAD_FLAC=".flac\:\s*error"
# REGEX_GOOD_FLAC=".flac\:\s*ok"

# prepare log and cache files
if [ ! -f $GOOD_LOG ]; then
	echo '---------------'
	echo $GOOD_LOG 'is missing. Creating one...'
    touch $GOOD_LOG
    echo 'Done.'
    echo '---------------'
fi
if [ ! -f $BAD_LOG ]; then
	echo '---------------'
	echo $BAD_LOG 'is missing. Creating one...' 
    touch $BAD_LOG
    echo 'Done.'
    echo '---------------'
fi
if [ ! -f $CACHE ]; then
	echo '---------------'
	echo $CACHE 'is missing. Creating one...' 
    touch $CACHE
    echo 'Done.'
    echo '---------------'
fi

# find flac files and do something with each of them
find $DIR -iname '*.flac' -print0 | while read -d $'\0' file; do
	# skip if this file has been analyzed before
	if [[ $(cat $GOOD_LOG | grep -F "$file") ]]; then
		echo '---------------'
		echo 'Skipping' $file
		echo 'This file has already been processed before.'
		echo '---------------'
		continue
	fi
	# process file else
	echo '---------------'
	echo 'Processing file:' $file
	flac -st "$file" > ./cache 2>&1
	FLAC=$(cat ./cache)
	if [[  $FLAC  ]]; then
		echo 'Houston, we have a problem! THE FLAC FILE HAS AN ERROR!'
		FILE_FLAC_VERSION=$(metaflac --show-vendor-tag "$file" 2>&1 | grep -oE $REGEX_VERSION | tr -dc '0-9')
		if [[ -z $FILE_FLAC_VERSION ]]; then
			echo 'I am unable to retrieve the flac version from the file.'
		elif [[ $FLAC_VERSION < $FILE_FLAC_VERSION ]]; then
			echo 'You are possibly using an OUTDATED FLAC VERSION.'
			echo 'Try to update your flac and run this script again after cleaning' $BAD_LOG '.'
		elif [[ $FLAC_VERSION > $FILE_FLAC_VERSION ]]; then
			echo 'The audio file is LIKELY CORRUPTED.'
		fi
		echo 'The file will be added to' $BAD_LOG
		# TODO: add file to bad_log.log
		echo $file >> $BAD_LOG
	else 
		echo 'Good news, everyone! THE FLAC FILE IS OKAY!'
		echo $file >> $GOOD_LOG
	fi
	# clean cache
	echo '' > ./cache
	echo '---------------'
done

echo '###############################################'
echo 'END OF THE SCRIPT'
echo '###############################################'

exit 0
