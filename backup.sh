#!/bin/sh

while read source
do
  echo $source
done < /home/snoopy/bin/backup.d/sources.list
