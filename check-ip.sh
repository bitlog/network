#!/bin/bash


IPS="$(ip a | grep -E '^[0-9]|inet' | awk '{print $2}' | sed ':a;N;$!ba;s/\(:\S*\)\n\([0-9]\S*\)/\1 \2/g' | grep -v '^lo: ' | sed 's/:$/: none/g')"

if tty -s; then
  echo "${IPS}"
else
  echo "${IPS}" | awk -F'/' '{print $1}' | awk '/$/ { printf(" | %s", $0); next } 1'
fi

exit 0
