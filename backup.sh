#!/bin/sh

EXCLUDES=/home/snoopy/bin/backup.d/exclude.list
BUACC="bijuws"
BUDEST="/media/All-in/backup/$BUACC"
BUDIR=`date +%Y-%m-%d`
DEST="$BUDEST/$BUDIR"
BUOPTS="--force --ignore-errors --delete-excluded --exclude-from=$EXCLUDES 
      --delete --backup --backup-dir=$DEST -a -R --progress"

while read source
do
  SOURCE="/$source"
  CURRENT="$BUDEST/current"
  #Clean PERIOD destanation dir
  rm -rf $DEST
  #create target dirs
  mkdir -p $DEST
  mkdir -p $CURRENT

  echo "$SOURCE > $DEST"
  sudo rsync $BUOPTS $SOURCE $CURRENT
done < /home/snoopy/bin/backup.d/sources.list
