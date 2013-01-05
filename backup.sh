#!/bin/sh


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $SCRIPT_DIR/config.conf

EXCLUDES="$SCRIPT_DIR/$SYSID/exclude.list"
BUACC="$SYSID"
BUDEST="/media/All-in/backup/$BUACC"
BUDIR=`date +%Y-%m-%d`
DEST="$BUDEST/$BUDIR"
BUOPTS="--force --ignore-errors --delete-excluded --exclude-from=$EXCLUDES 
      --delete --backup --backup-dir=$DEST -a -R -v"

while read source
do
  SOURCE="/$source"
  CURRENT="$BUDEST/current"
  echo "$SOURCE > $DEST"
  #sudo rsync $BUOPTS $SOURCE $CURRENT
done < $SCRIPT_DIR/$SYSID/sources.list
