#!/bin/bash

ARGS=`getopt -o "ifvhucd" --long "debug,create,interactive,force,version,verbose,help,usage,profile:,target-device:,target-device-path:" -n "$0" -- "$@"`
ARGSERR=$?

if [ $ARGSERR -ne "0" ]; then
  echo "Error"
  exit 1;
fi

eval set -- "$ARGS"


#Default options values
INTERACTIVE=false
FORCE=false
VERBOSE=false
PROFILE=""
CREATE=false
DEBUG=false
TARGET_DEVICE=""
TARGET_DEVICE_PATH=""

#Load config.
SCRIPT_DIR=`dirname $0`
SCRIPT_DIR=`cd $SCRIPT_DIR && pwd`
. $SCRIPT_DIR/config.conf


#Helper funxtions

function usage() {
  echo "Usage: $0 [-ifvhuc] `hostname`"
}

function show_help() {
  usage;
  echo "HELP TEXT"
}

function check_profile() {
  if [ $PROFILE ] && [ -d "$SCRIPT_DIR/$PROFILE" ] && [ -f "$SCRIPT_DIR/$PROFILE/config.conf" ]; then
    echo "Config found";
  else
    echo "$SCRIPT_DIR/$PROFILE/config.conf not found"
    unset -v PROFILE
  fi
}

function set_profile() {
  check_profile;
  while [ ! $PROFILE ] ; do
    if $INTERACTIVE ; then 
      if $CREATE ; then
        echo create profile
      else
        echo "Use \"`hostname`\"? [y/n]"
        while true ; do
          read ANSW;
          case $ANSW in
            "y") PROFILE="`hostname`"; break ;;
            "n") break; ;;
            *) echo "Write \"y\" or \"n\"" ;;
          esac
        done
        check_profile;
        if [ ! $PROFILE ] ; then
          echo Ask for existing profile
          echo "Press CTRL+C to cancel"
          read PROFILE;
          check_profile;
        fi
      fi #End create
    else #Not interactive
      echo "Error, no profile selected"
      exit 1;
    fi
  done #End
  if [ ! $PROFILE ] ; then 
    exit 1; 
  fi
}

function check_target_device_path() {
  if [ -h $TARGET_DEVICE ]; then
    TARGET_DEVICE=`readlink -f "$TARGETDEVICE"`
  fi
  TARGET_DEVICE_MOUNT=$(awk -v d=$DEVICE '$1 ~ d { print $2 }' < /proc/mounts)
  if [ ! $TARGER_DEVICE_MOUNT ] ; then
    return 1;
  else
    echo "Device mounted to $TARGET_DEVICE_MOUNT"
  fi

    
}

while true ; do
  case "$1" in
    -i|--interactive) INTERACTIVE=true ; shift ;;
    -f|--force) FORCE=true ; shift ;;
    -v|--verbose) VERBOSE=true ; shift ;;
    -h|--help) show_help; exit 0; shift ;;
    -u|--usage) usage; exit 0; shift ;;
    -c|--create) CREATE=true ; shift ;; 
    -d|--debug) DEBUG=true ; shift ;;
    --profile) PROFILE=$2 ; shift 2;;
    --target-device) TARGET_DEVICE=$2 ; shift 2;;
    --target-device-path) TARGET_DEVICE_PATH=$2; shift 2;;
    --) shift ; break ;;
    *) echo "Error!" ; exit 1 ;;
  esac
done

#Validtion


if [ $1 ] ; then PROFILE=$1; shift; fi


if $DEBUG ; then 
  echo "Remaining arguments:"; 
  for arg do echo '--> '"\`$arg'" ; done
fi

set_profile;

echo "Using $PROFILE profile."

if [ $? != 0 ] ; then echo "Error"; exit 1 ; fi

if $DEBUG ; then exit 1; fi

. $SCRIPT_DIR/$PROFILE/config.conf

if [ ! -d "$BUDESTDIR" ]; then
  echo "Dest dir "$BUDESTDIR" not exist"
  exit 1;
fi

EXCLUDES="$SCRIPT_DIR/$PROFILE/exclude.list"
BUDEST="$BUDESTDIR/$PROFILE"
BUDIR=`date +%Y-%m-%d`
DEST="$BUDEST/$BUDIR"
BUOPTS="--force --ignore-errors --delete-excluded --exclude-from=$EXCLUDES 
      --delete --backup --backup-dir=$DEST -a -R -v"

while read source
do
  SOURCE="$source"
  CURRENT="$BUDEST/current"
  echo "$SOURCE > $DEST"
  if ( ! $DEBUG ); then
    #Sudo required for system files backups
    rsync $BUOPTS $SOURCE $CURRENT
  fi
done < $SCRIPT_DIR/$PROFILE/sources.list
