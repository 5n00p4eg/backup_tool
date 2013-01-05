#!/bin/bash

SCRIPT_DIR=`dirname $0`
SCRIPT_DIR=`cd $SCRIPT_DIR && pwd`
. $SCRIPT_DIR/config.conf

if [ $1 ] && [ -d "$SCRIPT_DIR/$1" ]; then
  echo "YES";
fi

EXCLUDES="$SCRIPT_DIR/$SYSID/exclude.list"
BUACC="$SYSID"
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
  #sudo rsync $BUOPTS $SOURCE $CURRENT
done < $SCRIPT_DIR/$SYSID/sources.list
