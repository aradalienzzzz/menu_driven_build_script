#!/bin/bash

#Load Config File
source build_rom.conf

# Specify colors for shell
red='tput setaf 1'              # red
green='tput setaf 2'            # green
yellow='tput setaf 3'           # yellow
blue='tput setaf 4'             # blue
violet='tput setaf 5'           # violet
cyan='tput setaf 6'             # cyan
white='tput setaf 7'            # white
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) # Bold red
bldgrn=${txtbld}$(tput setaf 2) # Bold green
bldblu=${txtbld}$(tput setaf 4) # Bold blue
bldcya=${txtbld}$(tput setaf 6) # Bold cyan
normal='tput sgr0'

now=$(date +"%Y%m%d-%H%M")

## Function Builds Single Roms Specified From Menu System
function build_single_rom
{
  # set screen color and clear
  tput bold
  tput setaf 1
  clear

  # use CCACHE, disable NINJA, 2 days BUILD LOGS
  export USE_CCACHE=1
  export USE_NINJA=false
  export days_to_log=2
  export ANDROID_JACK_VM_ARGS="-Xmx4g -Dfile.encoding=UTF-8 -XX:+TieredCompilation"

  # kill any previous jack servers
  ./prebuilts/sdk/tools/jack-admin kill-server

  # clean main rom and out directory
  make clobber && make clean

  # set Resurrection Remix Build Type
  export RR_BUILDTYPE=OMS-OFFICIAL

  # set Rom EnvironMent and Initiate Device Build
  . build/envsetup.sh && brunch "${device[COUNTERB]}"

  # kill jack when done to prevent error on other builds
  ./prebuilts/sdk/tools/jack-admin kill-server

  # reset device counter 
  let COUNTERB=0
}


## Function Builds All Device Roms Specified From Menu System
function build_all_roms
{
  # use CCACHE, disable NINJA, 2 days BUILD LOGS
  export USE_CCACHE=1
  export USE_NINJA=false
  export days_to_log=2

  COUNTERB=1

  # repo sync all roms
  repo sync --force-sync -j16

  while [ $COUNTERB -lt 6 ]; do
    export ANDROID_JACK_VM_ARGS="-Xmx4g -Dfile.encoding=UTF-8 -XX:+TieredCompilation"

    # kill any previous jack servers
    ./prebuilts/sdk/tools/jack-admin kill-server

    # clean main rom and out directory
    make clobber && make clean

    # set Resurrection Remix Build Type
    export RR_BUILDTYPE=OMS-OFFICIAL

    # Set Rom EnvironMent and Initiate Device Build
    . build/envsetup.sh && brunch "${device[COUNTERB]}"

    # kill jack when done to prevent error on other builds
    ./prebuilts/sdk/tools/jack-admin kill-server

    # run ftp shell and upload rom to androidfilehost.com
    . ftp.sh

    let COUNTERB=COUNTERB+1
  done
}


# BUILD SINGLE ROM MENU
function subopt1
{
  subopt1=""
    while [ "$subopt1" != "x" ]
      do
      tput bold
      tput setaf 1
      clear
      COUNTERB=0
      echo Build Single Rom
      echo -e "${bldgrn}1) ${device[1]}"  >&2
      echo -e "${bldgrn}2) ${device[2]}"  >&2
      echo -e "${bldgrn}3) ${device[3]}"  >&2
      echo -e "${bldgrn}4) ${device[4]}"  >&2
      echo -e "${bldgrn}5) ${device[5]}"  >&2
      tput setaf 1
      echo x Back to Main Menu
      read -p "Select Option:" subopt1
        if [ "$subopt1" = "1" ]; then
               COUNTERB=1
               build_single_rom 2>&1 | tee echo "${device[COUNTERB]}_$now.log"
        elif [ "$subopt1" = "2" ]; then
               COUNTERB=2 
               build_single_rom 2>&1 | tee echo "${device[COUNTERB]}_$now.log"
        elif [ "$subopt1" = "3" ]; then
               COUNTERB=3
               build_single_rom 2>&1 | tee echo "${device[COUNTERB]}_$now.log"
        elif [ "$subopt1" = "4" ]; then
               COUNTERB=4
               build_single_rom 2>&1 | tee echo "${device[COUNTERB]}_$now.log"
        elif [ "$subopt1" = "5" ]; then
               COUNTERB=5
               build_single_rom 2>&1 | tee echo "${device[COUNTERB]}_$now.log"
        fi
  done
}


# BUILD ALL DEVICE ROMS MENU
function subopt2
{
  subopt2=""
    while [ "$subopt2" != "x" ]
      do
      tput bold
      tput setaf 1
      clear
      echo "Build All Device Roms (couple of hours)"
      echo "1) Build device roms for: ${device[1]} ${device[2]} ${device[3]} ${device[4]} ${device[5]}" >&2 
      tput setaf 1
      echo "x) Back to Main Menu"
      read -p "Select Option" subopt2
        if [ "$subopt2" = "1" ]; then
             build_all_roms 2>&1 | tee echo "build_all_$now.log"
        fi
  done
}


# Main Menu
function mainopt
{
  opt=""
    while [ "$opt" != "x" ]
      do
      tput bold
      tput setaf 1
      clear
      echo Main Menu
      echo "1) Build Single Rom"
      echo "2) Build All Device Roms" 
      echo "3) Repo Sync Rom"
      echo "x) To Quit"
      read -p "Select Option: " opt
        if   [ "$opt" = "1" ]; then
               #Go to Single Build Menu
               subopt1
        elif [ "$opt" = "2" ]; then
               #Go to Build All Devices Menu
               subopt2
        elif [ "$opt" = "3" ]; then
               #Repo Sync
               repo sync -f --force-sync -j16
        elif [ "$opt" = "x" ];then
             break
        fi
   done
}


mainopt
