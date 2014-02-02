#!/bin/bash
fundamentals=$HOME/git/courseware-fundamentals
cd $fundamentals
git checkout -- .
cd -
cd patches
for i in */* *
do
  [ -d $i ] && continue
  md=`echo $i |sed -e 's/\.patch//'`
  if [ -e $fundamentals/$md ]
  then
    echo "patching $i ..."
    patch -f $fundamentals/$md $i
  else
    echo "not found $fundamentals/$md ..."
  fi
done
