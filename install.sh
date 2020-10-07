#!/bin/bash
# author: cgomesu

install () {
	echo '---------'
	while [[ ! $response = 'y' && ! $response = 'n' ]]; do
		read -p 'Would you like to install the missing package now? (y/n): ' response
	done
	if [[ $response = 'n' ]]; then
		echo 'All packages are required.'
		echo 'Exiting the install.'
		exit 1
	fi
	# assuming debian/ubuntu via apt
	sudo apt-get install "$1" -yy
	echo '---------'
}

requisites () {
	echo 'Checking requisites...'
	REQUISITES=('flac' 'grep')
	for package in ${REQUISITES[@]}; do
		if [[ -z $(command -v $package) ]]; then
			echo 'The following program is not installed or cannot be found in this users $PATH:' $package
			install "$package"
		else
			echo $package': Okay!'
		fi
	done
}

echo '####################'
echo '## INSTALL SCRIPT ##'
echo '####################'
requisites
echo 'It seem we are all done here.'
echo 'Go ahead and try running ./flac_diag.sh now.'
exit 0
