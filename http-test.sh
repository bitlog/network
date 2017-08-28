#!/bin/bash


# check for sites
if [[ -z "${@}" ]]; then
  echo -e "\nA minimum of one URL is required to run: $(basename ${0}) www.google.com" >&2
  echo -e "\n$(basename ${0}) checks the URL for the domain encoded in SHA256." >&2
  echo -e "\nFor example, www.google.com would need to include the string:" >&2
  echo -e "656bfe9fcc14a574f65234d080320f895c82230ea789013e3303b7d9f4da9738\n" >&2
  exit 1
fi


# set global variables
CURL="curl -s -L --connect-timeout 3"
CHECKFILE="/tmp/$(basename ${0})_$(whoami)"
RUNS="3"


# check checkfile
if [[ -e "${CHECKFILE}" ]] && [[ ! -f "${CHECKFILE}" ]]; then
  echo -e "\n${CHECKFILE} exists and is not a regular file!\n"
  exit 1

elif [[ ! -e "${CHECKFILE}" ]]; then
  touch ${CHECKFILE} || exit 1
fi

if [[ ! -r "${CHECKFILE}" ]] || [[ ! -w "${CHECKFILE}" ]]; then
  echo -e "\nTest file ${CHECKFILE} is not not read/writeable!\n"
  exit 1
fi


# set functions
function check_file() {
  grep -q "${CALL}" ${CHECKFILE} || echo "${CALL} 0" >> ${CHECKFILE}
  NUM="$(grep "${CALL}" ${CHECKFILE} | awk '{print $2}')"
  NEW="${NUM}" && ((NEW++))
  sed -i "s/${CALL//\//\\/} ${NUM}/${CALL//\//\\/} ${NEW}/" ${CHECKFILE}

  # create alert message
  if [[ "$NEW" -eq ${RUNS} ]]; then
    if [[ "${SITE}" != "${i}" ]]; then
      MSG+="\n${SITE} - ${CALL}"
    else
      MSG+="\n${SITE}"
    fi
  fi
}


# run through sites
for i in ${@}; do
  # set variables
  CALL="http://${i}"
  SITE="${i}"

  # check if protocol is given
  if echo "${i}" | grep -qE "^https?://"; then
    CALL="${i}"
    SITE="$(echo "${i}" | awk -F'/' '{print $3}' | awk -F':' '{print $1}')"

  elif echo "${i}" | grep -qE "/|:"; then
    SITE="$(echo "${i}" | awk -F'/' '{print $1}' | awk -F':' '{print $1}')"
  fi

  # check website's HTTP status code
  sleep 1
  HTTP="$(${CURL} -o /dev/null -I -X GET -w "%{http_code}" "${CALL}")"

  # run alert if not OK
  if [[ "${HTTP}" != "200" ]]; then
    check_file

  # if HTTP status code 200
  else
    # check website for string
    GET="$(${CURL} "${CALL}")"
    CHECK="$(echo "${SITE}" | sha256sum | awk '{print $1}')"
    TEST="$(echo "${GET}" | grep -Eo "${CHECK}")"

    # run alert if not found
    if [[ -z "${TEST}" ]]; then
      check_file

    # erase notifications if found
    else
      sed -i "/${CALL//\//\\/}/d" ${CHECKFILE}
    fi
  fi
done


# output alert message
if [[ ! -z "${MSG}" ]]; then
  echo -e "HTTP alerts:\n${MSG}"
fi

# exit
exit $?
