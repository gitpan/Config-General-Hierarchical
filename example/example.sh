#!/bin/bash

for i in `ls` ; do
  if [ $i != example.sh ] ; then
    echo " \$ cat $i"
    cat $i | sed -e "s/^/ /"
    echo ""
  fi
done

for i in `ls *conf` ; do
  if [ $i != example.sh ] ; then
    echo " \$ ./$i"
    ./$i | sed -e "s/^/ /"
  fi
  echo ""
done
