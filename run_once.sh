#!/usr/bin/env bash
#
# This file has executed after container's builds
#
# tech-stack: ubuntu / apache / php
#
# @author demmonico
# @image ubuntu-apache-php
# @version v3.0



### users

# set root password
echo "root:${DMC_ROOT_PASSWD:-rootPasswd}" | chpasswd

# set apache user ID equal to host's owner ID
usermod -u ${DM_HOST_USER_ID} www-data && groupmod -g ${DM_HOST_USER_ID} www-data

# add dm user, set password, add to www-data group
DMC_DM_USER="${DMC_DM_USER:-dm}"
useradd -m ${DMC_DM_USER} && \
    usermod -a -G root ${DMC_DM_USER} && \
    usermod -a -G www-data ${DMC_DM_USER} && \
    adduser dm sudo && \
    echo "${DMC_DM_USER}:${DMC_DM_PASSWD:-${DMC_DM_USER}Passwd}" | chpasswd



# colored term
PS1="PS1='\[\033[01;35m\]\t\[\033[00m\] \${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;35m\]\${VIRTUAL_HOST}\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\\$ '"
# prepare to sed
PS1=$( echo ${PS1} | sed 's/\\/\\\\/g' )
# replace colors
declare -a RC_FILES=("/root/.bashrc" "/home/${DMC_DM_USER}/.bashrc")
for RC_FILE in "${RC_FILES[@]}"
do
#    echo "${RC_FILE}"
    START=$( cat ${RC_FILE} | sed "/^# set a fancy prompt/,\$d" )
    END=$( cat ${RC_FILE} | sed "/^# enable color support/,\$!d" )
    echo -e "${START}\n\n# set a fancy prompt\n${PS1}\n\n${END}" > ${RC_FILE}
done



### run custom script if exists
CUSTOM_ONCE_SCRIPT="${DMC_INSTALL_DIR}/custom_once.sh"
if [ -f ${CUSTOM_ONCE_SCRIPT} ]; then
    chmod +x ${CUSTOM_ONCE_SCRIPT} && source ${CUSTOM_ONCE_SCRIPT}
fi
