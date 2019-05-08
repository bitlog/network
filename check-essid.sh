#!/bin/bash

ESSID="$(/sbin/iwconfig 2> /dev/null | /bin/grep ESSID | /usr/bin/awk -F'ESSID:' '{print $2}' | /bin/sed -e 's/"//g' -e "s/ *$//")"

if [[ ! -z "${ESSID}" ]]; then
  echo " | SID: ${ESSID}"
fi

exit 0
