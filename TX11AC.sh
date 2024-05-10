#!/usr/bin/env bash
#By Atopes
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
if [[ -n $ASDEBUG ]]; then
	if [[ "${ASDEBUG}" != "true" ]]; then
		red "[E]: No ENV found. Exit."
		exit 1
	else
		set -x
	fi
fi
# ENV
X11APKURL="https://github.com/termux/termux-x11/releases/download/latest/app-arm64-v8a-debug.apk"
PROJREPO="https://github.com/AkinaAcct/TermuxX11AutoConfig"
PROJRAWURL="https://github.com/AkinaAcct/TermuxX11AutoConfig/raw/main"
# Often used func
print_help() {
	blue "Termux X11 Auto Config"
	blue "By AkinaAcct"
	blue ""
	blue "Usage:"
	blue "  -h,        print this help."
	blue ""
}
pause() {
	echo -e "\033[34m"
	read -p "[I]: Press enter to continue."
	echo -e "\033[0m"
}
# Arg solver
while getopts ":h" OPT; do
	case $OPT in
	h)
		print_help
        exit 0
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
		pkg up -y
		pkg install x11-repo tur-repo -y
		pkg install termux-x11-nightly -y
		pkg install mesa-zink virglrenderer-mesa-zink vulkan-loader-android -y
	else
		CHECK=$((CHECK + 1))
	fi
done
#               INFO:start config
while true; do
	blue "[I]: Select the type of container to use[R: root|P: proot]: "
	read CONTAINERTYPE
	case $CONTAINERTYPE in
	R)
		termux_starttx11_root
		break
		;;
	P)
		termux_starttx11
		break
		;;
	*)
		red "[E]: "
		pause
		;;
	esac
done
termux_starttx11_root() {
	cat <<-'EOF' >${PREFIX}/bin/starttx11-root
		#!/bin/bash
		    if [[ -z $* ]]; then
		        echo "You need to provide the path to the container root directory eg /path/to/container"
		        exit 1
		    fi
		    CONTAINERP=$1
		export TMPDIR=${CONTAINERP}/tmp
		export XKB_CONFIG_ROOT=${CONTAINERP}/usr/share/X11/xkb
		export XDG_RUNTIME_DIR=${TMPDIR}
		export CLASSPATH=$(/system/bin/pm path com.termux.x11 | cut -d: -f2)
		su -c "/system/bin/app_process / com.termux.x11.CmdEntryPoint :0"
	EOF
	chmod +x ${PREFIX}/bin/starttx11-root
}
termux_starttx11() {
	blue "[I]: Developing... Now exit."
	exit 0
}
