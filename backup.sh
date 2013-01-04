#!/bin/sh

EXCLUDES=/home/snoopy/bin/backup.d/exclude.list
BUACC="bijuws"
BUDEST="/media/All-in/backup/$BUACC"
BUDIR=`date +%M`
BUOPTS="--force --ignore-errors --delete-excluded --exclude-from=$EXCLUDES 
      --delete --backup --backup-dir=/$BUDIR -a"

while read source
do
  SOURCE="/$source"
  DEST="$BUDEST/$BUDIR/$source"
  CURRENT="$BUDEST/current/$source"
  #Clean PERIOD destanation dir
  rm -rf $DEST
  #create target dirs
  mkdir -p $DEST
  mkdir -p $CURRENT

  echo "$SOURCE > $DEST"
  rsync $BUOPTS $SOURCE $CURRENT
done < /home/snoopy/bin/backup.d/sources.list
