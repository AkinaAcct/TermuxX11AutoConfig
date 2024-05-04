#!/usr/bin/env bash
#By Atopes

# ENV
X11APKURL="https://github.com/termux/termux-x11/releases/download/latest/app-arm64-v8a-debug.apk"
PROJREPO="https://github.com/AtopesSayuri/TermuxX11AutoConfig"
PROJRAWURL="https://github.com/AtopesSayuri/TermuxX11AutoConfig/raw/main"
# Often used func
yellow() {
	echo -e "\033[33m${1}\033[0m"
}
blue() {
	echo -e "\033[34m${1}\033[0m"
}
green() {
	echo -e "\033[32m${1}\033[0m"
}
red() {
	echo -e "\033[31m${1}\033[0m"
}
check_debug_var() {
	if [[ "${ASDEBUG}" != "true" ]]; then
		red "[E]: No ENV found. Exit."
		exit 1
	else
		set -x
	fi
}
print_help() {
	blue "Termux X11 Auto Config"
	blue "By AtopesSayuri"
	blue ""
	blue "Usage:"
	blue "  -V,        verbose mode(need environment var. Check ${PROJREPO})."
	blue "  -h,        print this help."
	blue ""
}

# Arg solver
while getopts ":hV" OPT; do
	case $OPT in
	h)
		print_help
		;;
	V)
		check_debug_var
		;;
	:)
		red "[E]: Option -$OPTARG requires an argument." >&2 && exit 1
		;;

	?)
		red "E: Invalid option: -$OPTARG" >&2 && exit 1
		;;
	esac
done

#                              INFO: File Main Section

#               INFO: check packages
while [[ $CHECK -ne 2 ]]; do
	CHECK=0
	RESULT="$(pm list packages </dev/null 2>&1 | cat | grep package:com.termux.x11)"
	if [[ -z $RESULT ]]; then
		yellow "[W]: Termux:x11 APP is not installed. Downloading now..."
		curl -L $X11APKURL -o X11.apk || RET=$?
		if [[ $RET -ne 0 ]]; then
			red "[E]: Download failed. Check your internet connection."
			exit $RET
		else
			mv X11.apk /sdcard/ || exit $?
			blue "[I]: Downloaded file in /sdcard/X11.apk. Install it and then return to here."
		fi
	else
		CHECK=$((CHECK + 1))
	fi
	if (! command -v termux-x11 >/dev/null 2>&1); then
		yellow "[W]: Termux:X11 package is not installed in Termux environment. Installing now..."
		pkg install termux-x11-nightly -y
	else
		CHECK=$((CHECK + 1))
	fi
done
#               INFO:start config

