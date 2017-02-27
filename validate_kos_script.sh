#!/usr/bin/env bash

for f in $(find ~/workspace/kOS/v0.2 -type f)
do
  if [ "${f: -11}" == "_errors.txt" ]
  then
    echo "Removing $f"
    rm $f
  fi
done

for f in $(find ~/workspace/kOS/v0.2 -type f)
do
  if [ "${f: -3}" == ".ks" ]
  then
    echo "Validating $f"
    wine ~/workspace/KSTools/KSValidator/bin/Release/KSValidator.exe --file=$f > "${f%???}_errors.txt"
  fi
done

for f in $(find ~/workspace/kOS/v0.2 -type f)
do
  line=$(head -n 1 $f)
  if [ "${line:0:13}" == "code contains" ]
  then
    echo "No errors found in $f"
    rm $f
  fi
done
