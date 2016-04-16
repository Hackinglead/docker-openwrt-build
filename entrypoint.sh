#!/bin/bash

###########################
#
# Docker EntryPoint script
#
###########################

# Set premissions to /data catalog
sudo chown openwrt:openwrt /data

INPUT=/tmp/menu.sh.$$
OUTPUT=/tmp/output.sh.$$

# vi
vi_editor=${EDITOR-vi}

# Repo
REPO_URL="git://git.openwrt.org/15.05/openwrt.git"
# build-dir
DATA_VOLUME="/data"
BUILD_DIR="${DATA_VOLUME}/openwrt"
BUILD_CONFIG="${BUILD_DIR}/.config"

# trap and delete temp files
trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

# Purpose - display output using msgbox
function display_output(){
	local h=${1-10}
	local w=${2-41}
	local t=${3-Output}
	local m=${4}
	dialog --backtitle "OpeWRT build root" --title "${t}" --clear --msgbox "${m}" ${h} ${w}
}


# Press any key :)
function pause(){
  read -n1 -r -p "Press any key..."
}

# Run make menuconfig
function wrt_menu(){
	make -C "${BUILD_DIR}" menuconfig
}

# Update feeds
function feeds_update(){
	${BUILD_DIR}/scripts/feeds update -a
  pause
}

# Install all Packages
function feeds_install_all(){
	${BUILD_DIR}/scripts/feeds install -a
  pause
}

# Get source code
function get_source(){
	if [ ! -d "${BUILD_DIR}" ]; then
  	git clone "${REPO_URL}" "${BUILD_DIR}"
	else
		cd "${BUILD_DIR}" && git pull
  fi
	  cd "${DATA_VOLUME}" && feeds_update
}

# Run build firmware
function build_firmware(){
	if [ ! -d "${BUILD_DIR}" ]; then
		display_output 10 41 "Error" "Build root not found, get source before build"
	else
		if [ ! -f "${BUILD_CONFIG}" ]; then
			display_output 10 41 "Error" "Config file not found, run Build menu before build firmware"
		else
		  dialog --backtitle "Build config" --title "Set threads num" --clear --inputbox "Threads - set processor core num + 1" 8 60 2>"${INPUT}"
		  return_value=$?
		  if [ "$return_value" == "0" ]; then
		    make -C "${BUILD_DIR}" -j `cat ${INPUT}`
		    pause
		  fi
		fi
	fi
}


while true
do

# display menu
dialog --clear   --backtitle "OpeWRT build root" \
--cancel-label "Exit" \
--title "Build root menu" \
--menu "Choise command" 15 60 7 \
"Get/Update" "Get/Update sourcecode" \
"Update feeds" "Update WRT feeds" \
"Pkg Install" "Install Packages" \
"Build menu" "Run WRT build menu" \
"Build Firmware" "Run build" \
"MC" "Run Midnight Commander" \
"SHELL" "Run system shell" 2>"${INPUT}"

# Exit button
if test $? -eq 1; then
  break
fi

menuitem=$(<"${INPUT}")
  case $menuitem in
  	"Get/Update") get_source;;
  	"Update feeds") feeds_update;;
    "Pkg Install") feeds_install_all;;
    "Build menu") wrt_menu;;
  	"Build Firmware") build_firmware;;
		"MC") mc;;
    "SHELL") bash;;
  	#Exit) echo "Bye"; break;;
  esac
done

# temp files found?, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
