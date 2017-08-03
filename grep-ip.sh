#!/bin/bash


# check that arguments are given
if [[ -z "${@}" ]]; then
  echo -e "\nRun \"$(basename ${0}) /path/to/file\" to search file for IPv4 addresses and format them correctly.\n" >&2
  exit 1
fi


# set required variables
GREP_IPS="\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
TERM_WIDTH="$(tput cols)"
COLUMNS="$(printf '%*s\n' "${TERM_WIDTH}" '' | tr ' ' -)"


# create functions
function sed-ips() {
 sed -e 's/0\./A\./g' -e 's/\.0$/\.A/g' -e 's/^0*//g' -e 's/\.0*/\./g' -e 's/A\./0\./g' -e 's/\.A/\.0/g'
}


# run through arguments
echo
for i in "${@}"; do
  # clear variables
  unset IPS

  # prepare nice output
  echo -e "${COLUMNS}\n"

  # check that argument is file
  if [[ -f "${i}" ]]; then
    # get IPs and remove unnecessary zeroes
    IPS="$(grep -ohE $(echo "${GREP_IPS}") ${i} | sed-ips | sort -n | uniq)"

    # output found IPs
    if [[ ! -z "${IPS}" ]]; then
      echo -e "Found IPv4 addresses in: ${i}\n"
      echo "${IPS}"

    # output error message if no IPs found
    else
      echo "No IPv4 addresses in: ${i}"
    fi

  # if not a file, output error
  else
    echo "Not a file: ${i}"
  fi

  # finish run through argument
  echo
done


# end output
echo -e "${COLUMNS}\n"
exit $?
