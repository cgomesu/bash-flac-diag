# bash-flac-diag
This is a simple bash script to test [FLAC audio files](https://en.wikipedia.org/wiki/FLAC) recursively and generate logs with good files (no errors found) and bad ones (at least one error found).  The script tests flac files with the help of [flac cli encoder/decoder](https://xiph.org/flac/documentation_tools_flac.html), which detects errors in the stream and when 

> the MD5 signature of the decoded audio does not match the stored MD5 signature, even when the bitstream is valid.

This tool is meant to be used to identify corrupted flac files that should be deleted from an audio library, for example.

# Requisites
* [**flac cli**](https://xiph.org/flac/download.html). Most distributions have a flac package. In Debian, for example, you can run `apt get install flac` to install the cli.
* standard linux packages (namely, *echo, mkdir, date, cat, find, touch, grep, tr*). If you're running a mainstream distro, you don't need to worry about installing any one of them.  

When running the **`flac_diag.sh`**, the script will attempt to detect all necessary programs and if there's one missing, you'll see a message about it.  Make sure that if they're installed, they're also in your user's `$PATH`.

# Usage
To scan and test all flac files inside a music folder recursively, simply run the script adding the **`/full/path/to/music/folder/`** as argument, as follows:

`./flac_diag.sh /path/to/music/folder/`

or

`bash flac_diag.sh /path/to/music/folder/`

The script will create a `./log` subfolder with two log files, namely `bad_flacs.log` and `good_flacs.log`.  The former has a list with the path of each .flac file that has produced at least a single error when running the `flac` utility in test mode, while the latter has a list with the path of each .flac file that has not produced any errors.  A detailed description of all errors produced by each file are stored on `./log/errors/` for debugging.

In most cases, after testing all .flac files, you'd want to:

1. Double check a few files in `bad_flacs.log`, to make sure they are actually corrupted;
2. Then remove all files in `bad_flacs.log` from your music folder.

To remove the bad .flac files, you can use a tool in the `./tools` subfolder called **`bad_flac_remover.sh`**, which takes a `bad_flacs.log` as argument and deletes every single file listed in there.  As usual, please be careful with that.
