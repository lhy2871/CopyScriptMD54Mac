#!/bin/bash
#Copyright (C) 2016 Hanyuan Liu (lhy2871@126.com)
#md5sumd is a very fast md5 checksum program written by Bo Peng (bpeng@mdanderson.org), url=http://varianttools.sourceforge.net/Utility/Md5sumd
set -u #use utf-8
LANG="" #use default language coding
folder="${1##*/}" #get the latest file folder which contans the main files
function show_error {
	echo -e "\033[41;37;5m\n\nCpoy FAILD!!!\a\nCopy FAILD!!!\a\nCopy FAILD!!!\a\nCopy FAILD!!!\a\nCopy FAILD!!!\a\nCopy FAILD!!!\n\033[0m"
}
function show_error_md5 {
	echo -e "\033[41;37;5m\n\nMD5 Check FAILD!!!\a\nMD5 Check FAILD!!!\a\nMD5 Check FAILD!!!\a\nMD5 Check FAILD!!!\a\nMD5 Check FAILD!!!\a\nMD5 Check FAILD!!!\n\033[0m"
}

clear
echo    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo -e "@ Script written by Hanyuan  Nov-20-2016 @"
echo    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

echo -e "Source folder is \033[42;37;1m"${folder}"\033[0m"
echo -e "Target path is   \033[42;37;1m"$2"\033[0m"

rsync -a --info=progress2,stats --exclude=".*" --exclude="./.*" "$1" "$2"
#main function <!-- use rsync version > 3.1 --!>
if [ "$?" = "0" ];then # if copid successfully
	echo -e "\n\033[42;37;1mCopy Success!\033[0m\n"
else
	show_error
	exit 1
fi

echo -e "Starting MD5 Checksum...\nPlease Wait...\nGenerating Source MD5"

#MD5 checksum
if [ -z "$1" ];then # if the source foder is not empty
	echo "Source folder is empty.\nexit MD5 check...\n"
	exit 0
else
	cd "$1"
	find . -type f ! -name ".*" ! -path "*/.*" -print0 | xargs -0 md5 | sort > /tmp/s_md5.log
	#find . -type f ! -name ".*" ! -path "*/.*" -print0 | xargs -0 md5sumd | sort > /tmp/s_md5.log
fi
if [ -s "/tmp/s_md5.log" ];then
	echo -e "Source MD5 Generated\nGenerating Target MD5"
else
	show_error_md5
	exit 1
fi

cd "$2""/""$folder"
find . -type f ! -name ".*" ! -path "*/.*" -print0 | xargs -0 md5 | sort > /tmp/t_md5.log
#find . -type f ! -name ".*" ! -path "*/.*" -print0 | xargs -0 md5sumd | sort > /tmp/t_md5.log
if [ -s "/tmp/t_md5.log" ];then
	echo "Target MD5 Generated"
else
	show_error_md5
	exit 1
fi

diff /tmp/s_md5.log /tmp/t_md5.log
if [ "$?" = "0" ];then
	echo -e "\033[42;37;1mMD5 Check Passed!\033[0m\n\033[42;37;1mCongratulations!\033[0m\n"
else
	show_error_md5
	exit 1
fi

#made log file
md5logname="${folder%/*}""_""$(date +%Y%b%d)""$(date +_%H%M)""_md5.log"
cp /tmp/t_md5.log "$2""/""$md5logname"
rm -rf /tmp/s_md5.log /tmp/t_md5.log
exit 0
