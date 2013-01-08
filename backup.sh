#!/bin/bash

ARGS=`getopt -o "ifvhuc" --long "create,interactive,force,version,verbose,help,usage,profile:" -n "$0" -- "$@"`
ARGSERR=$?
echo "CODE=$ARGSERR"
echo "ARGS=$ARGS"

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
#  if [ $1 ] && [ -d "$SCRIPT_DIR/$1" ] && [ -f "$SCRIPT_DIR/$1/config.conf" ]; then
#   echo "Config found";
#  else
#    if [ $1 ]; then
#      echo "$SCRIPT_DIR/$1/config.conf not found"
#      exit 1;
#    else
#      echo "Usage: $0 `hostname`"
#      exit 1;
#    fi
#  fi
exit 1;
}

function set_profile() {
  echo "PROFILE = $PROFILE"
  if [ ! $PROFILE ] ; then
    echo "No profile present"
    if $INTERACTIVE ; then 
      if $CREATE ; then
        #create profile
        exit 1;
      else
        #Ask for existing profile
        exit 1;
      fi #End create
      exit 1;
    else #Not interactive
      exit 1;
    fi
  else #Profile string present
    exit 1;
  fi #End
}

while true ; do
  case "$1" in
    -i|--interactive) INTERACTIVE=true ; shift ;;
    -f|--force) FORCE=true ; shift ;;
    -v|--verbose) VERBOSE=true ; shift ;;
    -h|--help) show_help; exit 0; shift ;;
    -u|--usage) usage; exit 0; shift ;;
    -c|--create) CREATE=true ; shift ;; 
    --profile) PROFILE=$2 ; shift 2;;
    --) shift ; break ;;
    *) echo "Error!" ; exit 1 ;;
  esac
done

if [ $1 ] ; then PROFILE=$1; shift; fi

#echo "Remaining arguments:"
#for arg do echo '--> '"\`$arg'" ; done

set_profile;

if [ $? != 0 ] ; then echo "Error"; exit 1 ; fi

exit 1;

. $SCRIPT_DIR/$1/config.conf

if [ ! -d "$BUDESTDIR" ]; then
  echo "Dest dir "$BUDESTDIR" not exist"
  exit 1;
fi

EXCLUDES="$SCRIPT_DIR/$1/exclude.list"
BUACC="$1"
BUDEST="$BUDESTDIR/$BUACC"
BUDIR=`date +%Y-%m-%d`
DEST="$BUDEST/$BUDIR"
BUOPTS="--force --ignore-errors --delete-excluded --exclude-from=$EXCLUDES 
      --delete --backup --backup-dir=$DEST -a -R -v"

while read source
do
  SOURCE="$source"
  CURRENT="$BUDEST/current"
  echo "$SOURCE > $DEST"
  if [ ! $DEBUG ]; then
    #Sudo required for system files backups
    sudo rsync $BUOPTS $SOURCE $CURRENT
  fi
done < $SCRIPT_DIR/$1/sources.list

