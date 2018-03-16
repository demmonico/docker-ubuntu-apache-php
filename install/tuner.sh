#!/usr/bin/env bash
#
# Tuner for DM's containers system configs
#
# @author demmonico
# @link https://github.com/demmonico
# @image ubuntu-apache-php
#



# memory_limit
function applyPhpMemoryLimit()
{
    local PHP_INI=$1
    local MAXSIZE_INPUT=$2
    local MAXSIZE="$( echo "${MAXSIZE_INPUT}" | sed -E "s/^([[:digit:]]*)[A-Za-z]*$/\1/g" )"
    local UNIT="$( echo "${MAXSIZE_INPUT}" | sed -E "s/^[[:digit:]]*([A-Za-z]*)$/\1/g" )"
    if [ -z "${MAXSIZE_INPUT}" ] || [ -z "${MAXSIZE}" ]; then
        echo "Error: value 'memory_limit' = ${MAXSIZE_INPUT} could be defined"
        exit
    fi

    # get free physical memory Kb
    local MEMORY_FREE="$(($( grep MemFree /proc/meminfo | awk '{print $2}' )/1024))M"
    local MEMORY_FREE_VALUE="$( echo "${MEMORY_FREE}" | sed -E "s/^([[:digit:]]*)[A-Za-z]*$/\1/g" )"
    local MEMORY_FREE_UNIT="$( echo "${MEMORY_FREE}" | sed -E "s/^[[:digit:]]*([A-Za-z]*)$/\1/g" )"
    # try to check free memory
    if [ ! -z "${MEMORY_FREE}" ] && [ ! -z "${MEMORY_FREE_VALUE}" ] && [ "${UNIT}" == "${MEMORY_FREE_UNIT}" ] && [ "${MAXSIZE}" -gt "${MEMORY_FREE_VALUE}" ]; then
        echo "Error: value 'memory_limit' = ${MAXSIZE_INPUT} could be more then free memory size (${MEMORY_FREE})"
        exit
    fi

    # memory_limit
    local PARAM='memory_limit'
    sudo sed -i -E "s/^${PARAM}.*\$/${PARAM} = ${MAXSIZE}${UNIT}/g" ${PHP_INI}
}


# post_max_size
function applyPhpPostMaxSize()
{
    local PHP_INI=$1
    local MAXSIZE_INPUT=$2
    local MAXSIZE="$( echo "${MAXSIZE_INPUT}" | sed -E "s/^([[:digit:]]*)[A-Za-z]*$/\1/g" )"
    local UNIT="$( echo "${MAXSIZE_INPUT}" | sed -E "s/^[[:digit:]]*([A-Za-z]*)$/\1/g" )"
    if [ -z "${MAXSIZE_INPUT}" ] || [ -z "${MAXSIZE}" ]; then
        echo "Error: value 'post_max_size' = ${MAXSIZE_INPUT} could be defined"
        exit
    fi

    # post_max_size
    local PARAM='post_max_size'
    sudo sed -i -E "s/^${PARAM}.*\$/${PARAM} = ${MAXSIZE}${UNIT}/g" ${PHP_INI}

    # memory_limit
    local MEMORY_LIMIT=$((MAXSIZE*16))
    echo "$( applyPhpMemoryLimit "${PHP_INI}" "${MEMORY_LIMIT}${UNIT}" )"
}


# upload_max_filesize
function applyPhpUploadMaxFileSize()
{
    local PHP_INI=$1
    local MAXSIZE_INPUT=$2
    local MAXSIZE="$( echo "${MAXSIZE_INPUT}" | sed -E "s/^([[:digit:]]*)[A-Za-z]*$/\1/g" )"
    local UNIT="$( echo "${MAXSIZE_INPUT}" | sed -E "s/^[[:digit:]]*([A-Za-z]*)$/\1/g" )"
    if [ -z "${MAXSIZE_INPUT}" ] || [ -z "${MAXSIZE}" ]; then
        echo "Error: value 'upload_max_filesize' = ${MAXSIZE_INPUT} could be defined"
        exit
    fi

    # upload_max_filesize
    local PARAM='upload_max_filesize'
    sudo sed -i -E "s/^${PARAM}.*\$/${PARAM} = ${MAXSIZE}${UNIT}/g" ${PHP_INI}

    # post_max_size
    local POSTMAXSIZE=$((MAXSIZE*4))
    echo "$( applyPhpPostMaxSize "${PHP_INI}" "${POSTMAXSIZE}${UNIT}" )"
}


# max_execution_time
function applyPhpMaxExecTime()
{
    local PHP_INI=$1
    local MAXTIME=$2
    if [ -z "${MAXTIME}" ]; then
        echo "Error: value 'max_execution_time' = ${MAXTIME} can not be defined"
        exit
    fi

    local PARAM='max_execution_time'
    sudo sed -i -E "s/^${PARAM}.*\$/${PARAM} = ${MAXTIME}/g" ${PHP_INI}
}


# max_input_time
function applyPhpMaxInputTime()
{
    local PHP_INI=$1
    local MAXTIME=$2
    if [ -z "${MAXTIME}" ]; then
        echo "Error: value 'max_input_time' = ${MAXTIME} can not be defined"
        exit
    fi

    local PARAM='max_input_time'
    sudo sed -i -E "s/^${PARAM}.*\$/${PARAM} = ${MAXTIME}/g" ${PHP_INI}
}
