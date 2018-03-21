#!/usr/bin/env bash
#
# This file has executed each time when container's starts
#
# tech-stack: ubuntu / apache / php
#
# @author demmonico
# @image ubuntu-apache-php
# @version v3.2.1



##### run once
if [ -f "${DMC_RUN_ONCE_FLAG}" ]; then
  # run script once
  source /run_once.sh
  # rm flag
  /bin/rm -f ${DMC_RUN_ONCE_FLAG}
fi



##### run
cd ${DMC_APP_PROJECT_DIR}



### set dummy if defined
PROJECT_DUMMY_DIR="${DMC_APP_PROJECT_DIR}/dummy"

function setDummyStatus
{
    local msg=$@;
    if [ -n "$msg" ] && [ -d "${DMC_APP_APACHE_DUMMY_DIR}" ]; then
        ( echo "$msg"; ) | sudo tee ${PROJECT_DUMMY_DIR}/status
    fi;
}

if [ -d "${DMC_APP_APACHE_DUMMY_DIR}" ]; then

    # replace htaccess files
    if [ ! -d "${PROJECT_DUMMY_DIR}" ]; then
        cp -rf ${DMC_APP_APACHE_DUMMY_DIR} ${PROJECT_DUMMY_DIR}
        if [ -f "${DMC_APP_PROJECT_DIR}/.htaccess" ]; then
            cp ${DMC_APP_PROJECT_DIR}/.htaccess ${DMC_APP_PROJECT_DIR}/real.htaccess
        fi
        yes | cp -rf ${DMC_APP_APACHE_DUMMY_DIR}/.htaccess ${DMC_APP_PROJECT_DIR}/.htaccess
    fi

    # start apache for dummy
    setDummyStatus "Starting apache";
    service apache2 start
fi



### tune system configs
if [ ! -z "${DMC_APP_APACHE_UPLOADMAXFILESIZE}" ] || \
    [ ! -z "${DMC_APP_APACHE_POSTMAXSIZE}" ] || \
    [ ! -z "${DMC_APP_APACHE_MEMORYLIMIT}" ] || \
    [ ! -z "${DMC_APP_APACHE_MAXEXECTIME}" ] || \
    [ ! -z "${DMC_APP_APACHE_MAXINPUTTIME}" ]
then
    PHP_VER="$( php -v | grep '(cli)' | sed -E "s/^PHP\s([[:digit:]]\.[[:digit:]]).*/\1/g" )"

    #cat /etc/php/7.0/apache2/php.ini | grep 'post_max_size\|upload_max_filesize\|memory_limit'
    declare -a PHP_INI_FILES=("/etc/php/${PHP_VER}/apache2/php.ini")

    isRestartApache=''
    for PHP_INI_FILE in "${PHP_INI_FILES[@]}"
    do
        if [ -f "${PHP_INI_FILE}" ]; then
            source "${DMC_INSTALL_DIR}/tuner.sh"

            #cat ${PHP_INI_FILE} | grep 'post_max_size\|upload_max_filesize\|memory_limit\|max_execution_time\|max_input_time'

            # upload_max_filesize
            if [ ! -z "${DMC_APP_APACHE_UPLOADMAXFILESIZE}" ]; then
                tune_errors="$( applyPhpUploadMaxFileSize "${PHP_INI_FILE}" "${DMC_APP_APACHE_UPLOADMAXFILESIZE}" )"

                # TODO-dep tune logs
                [ ! -z "${tune_errors}" ] && echo -e "[$( date '+%F %T.%N %Z' )] ${tune_errors}" >> /tmp/dm.log
            fi

            # post_max_size
            if [ ! -z "${DMC_APP_APACHE_POSTMAXSIZE}" ]; then
                tune_errors="$( applyPhpPostMaxSize "${PHP_INI_FILE}" "${DMC_APP_APACHE_POSTMAXSIZE}" )"

                # TODO-dep tune logs
                [ ! -z "${tune_errors}" ] && echo -e "[$( date '+%F %T.%N %Z' )] ${tune_errors}" >> /tmp/dm.log
            fi

            # memory_limit
            if [ ! -z "${DMC_APP_APACHE_MEMORYLIMIT}" ]; then
                tune_errors="$( applyPhpMemoryLimit "${PHP_INI_FILE}" "${DMC_APP_APACHE_MEMORYLIMIT}" )"

                # TODO-dep tune logs
                [ ! -z "${tune_errors}" ] && echo -e "[$( date '+%F %T.%N %Z' )] ${tune_errors}" >> /tmp/dm.log
            fi

            # max_execution_time
            if [ ! -z "${DMC_APP_APACHE_MAXEXECTIME}" ]; then
                tune_errors="$( applyPhpMaxExecTime "${PHP_INI_FILE}" "${DMC_APP_APACHE_MAXEXECTIME}" )"

                # TODO-dep tune logs
                [ ! -z "${tune_errors}" ] && echo -e "[$( date '+%F %T.%N %Z' )] ${tune_errors}" >> /tmp/dm.log
            fi

            # max_input_time
            if [ ! -z "${DMC_APP_APACHE_MAXINPUTTIME}" ]; then
                tune_errors="$( applyPhpMaxInputTime "${PHP_INI_FILE}" "${DMC_APP_APACHE_MAXINPUTTIME}" )"

                # TODO-dep tune logs
                [ ! -z "${tune_errors}" ] && echo -e "[$( date '+%F %T.%N %Z' )] ${tune_errors}" >> /tmp/dm.log
            fi

            #cat ${PHP_INI_FILE} | grep 'post_max_size\|upload_max_filesize\|memory_limit\|max_execution_time\|max_input_time'

            isRestartApache='yes'
        fi
    done

    # restart Apache
    [ ! -z "${isRestartApache}" ] && sudo service apache2 restart
fi



### run custom script if exists
CUSTOM_SCRIPT="${DMC_INSTALL_DIR}/custom.sh"
if [ -f ${CUSTOM_SCRIPT} ]; then
    chmod +x ${CUSTOM_SCRIPT} && source ${CUSTOM_SCRIPT}
fi
if [ ! -z "${DMC_CUSTOM_RUN_COMMAND}" ]; then
    eval ${DMC_CUSTOM_RUN_COMMAND}
fi



# wait for db
if [ ! -z "${DMC_DB_SERVICE}" ]
then
    # update status
    setDummyStatus "Wait for db container";
    # wait
    while ! mysqladmin ping -h"${DMC_DB_SERVICE}" --silent; do
        sleep 1
    done
fi



### stop dummy
if [ -d "${DMC_APP_APACHE_DUMMY_DIR}" ]; then

    # stop apache
    setDummyStatus "Starting container";
    service apache2 stop

    # rm dummy
    if [ -f "${DMC_APP_PROJECT_DIR}/real.htaccess" ]; then
        yes | cp -rf ${DMC_APP_PROJECT_DIR}/real.htaccess ${DMC_APP_PROJECT_DIR}/.htaccess
        /bin/rm -f ${DMC_APP_PROJECT_DIR}/real.htaccess
    else
        /bin/rm -f ${DMC_APP_PROJECT_DIR}/.htaccess
    fi
    /bin/rm -rf ${PROJECT_DUMMY_DIR}
fi



### FIX permissions
chown -R www-data:www-data ${DMC_APP_PROJECT_DIR}



### FIX cron start
cron



#### run supervisord
exec /usr/bin/supervisord -n
