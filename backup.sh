#!/bin/bash
SCRIPT_DIR=`dirname $0`
SCRIPT_DIR=`cd $SCRIPT_DIR && pwd`
. $SCRIPT_DIR/config.conf

if [ $1 ] && [ -d "$SCRIPT_DIR/$1" ] && [ -f "$SCRIPT_DIR/$1/config.conf" ]; then
 echo "Config found";
else
  if [ $1 ]; then
    echo "$SCRIPT_DIR/$1/config.conf not found"
    exit 1;
  else
    echo "Usage: $0 backup_name"
    exit 1;
  fi
fi

. $SCRIPT_DIR/$1/config.conf

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
  #Sudo required for system files backups
  sudo rsync $BUOPTS $SOURCE $CURRENT
done < $SCRIPT_DIR/$1/sources.list

