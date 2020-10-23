# bash-flac-diag
This is a simple bash script for Linux to test [FLAC audio files](https://en.wikipedia.org/wiki/FLAC) recursively and generate logs with good files (no errors found) and bad ones (at least one error found).  The script tests flac files with the help of [flac cli encoder/decoder](https://xiph.org/flac/documentation_tools_flac.html), which detects errors in the stream and when 

> the MD5 signature of the decoded audio does not match the stored MD5 signature, even when the bitstream is valid.

This tool is meant to be used to identify corrupted flac files that should be deleted from an audio library, for example. Here's a demo of it:

<p align="center">
	<a href="https://youtu.be/tPYSjBmLUFs"><img src="img/demo-slow.gif"></a>
</p>


# Requisites
* [**flac cli**](https://xiph.org/flac/download.html). Most distributions have a flac package.

* **Standard Linux packages**. (If you're running a mainstream distro, you don't need to worry about installing any one of them.)  

When running **`flac_diag.sh`**, the script will attempt to detect all necessary programs and if there's one missing, you'll see a message about it.  Make sure that if they're installed, they're also in your user's `$PATH`.

# Installation
I've only tested this script with Debian and Ubuntu but it probably works just fine with any other standard Linux distro.

## Debian/Ubuntu

* Via git

```
sudo apt update
sudo apt install git -yy
cd /opt
sudo git clone https://github.com/cgomesu/bash-flac-diag.git
sudo chmod +x bash-flac-diag/ -R
cd bash-flac-diag/
./install.sh
```

* Via github cli

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
sudo apt-add-repository https://cli.github.com/packages
sudo apt update
sudo apt install gh
cd /opt
sudo gh repo clone cgomesu/bash-flac-diag
sudo chmod +x bash-flac-diag/ -R
cd bash-flac-diag/
./install.sh
```

# Usage
To scan and test all flac files inside a music folder recursively, simply run the script adding the **`/full/path/to/music/folder/`** as argument, as follows:

`./flac_diag.sh /path/to/music/folder/`

or

`bash flac_diag.sh /path/to/music/folder/`

The script will create a `./log` subfolder with two log files, namely `bad_flacs.log` and `good_flacs.log`.  The former has a list with the path of each .flac file that has produced at least a single error when running the `flac` utility in test mode, while the latter has a list with the path of each .flac file that has not produced any errors.  A detailed description of all errors produced by each file are stored on `./log/errors/` for debugging.

*(Optional: If you wish to create a log file with the output of the `flac_diag.sh` script, you can simply redirect the output to a file of your preference.  For example, to output to a file called `output-10-06-2020.log`, simply run `bash flac_diag.sh /path/to/music/folder/ > output-10-06-2020.log`.)*

In most cases, after testing all .flac files, you'd want to:

1. Double check a few files in `bad_flacs.log`, to make sure they are actually corrupted;
2. Make a backup of the current `bad_flacs.log` files;
3. Attempt to fix the files in `bad_flacs.log` by re-enconding them; then manually recheck the files or clean the `bad_flacs.log` and re-run the `flac_diag.sh` script;
4. Then if re-encoding doesn't work as expected, remove all files in `bad_flacs.log` from your music folder.


## Fixing bad flac files
To attemp to fix the bad .flac files, you can use a tool in the `./tools` subfolder called **`bad_flac_fixer.sh`**, which takes a `bad_flacs.log` as argument and overwrites every single file listed in there with a re-encoded version of it. To fix all files listed in `./log/bad_flacs.log`, run the following from the git root folder:

`./tools/bad_flac_fixer.sh log/bad_flacs.log` or `bash tools/bad_flac_fixer.sh log/bad_flacs.log`

**Make a backup of your `bad_flacs.log`**, delete/clean the old `./log/bad_flacs.log`, and re-run the `flac_diag.sh` script.  If the errors persist, I suggest to remove the bad files.


## Removing bad flac files
To remove the bad .flac files, you can use a tool in the `./tools` subfolder called **`bad_flac_remover.sh`**, which takes a `bad_flacs.log` as argument and deletes every single file listed in there. To delete all files listed in `./log/bad_flacs.log`, run the following from the git root folder:

`./tools/bad_flac_remover.sh log/bad_flacs.log` or `bash tools/bad_flac_remover.sh log/bad_flacs.log`

