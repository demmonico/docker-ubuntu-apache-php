# Dockerfile for build app container
#
# tech-stack: ubuntu / apache / php
#
# @author demmonico
# @image ubuntu-apache-php
# @version v3.2.1


FROM ubuntu:14.04
MAINTAINER demmonico@gmail.com


### ENV CONFIG
ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# for mc
ENV TERM xterm

# dummy inner location
ENV DMC_APP_APACHE_DUMMY_DIR="/dm-app-dummy"

# additional files required to run container
ENV DMC_INSTALL_DIR="/dm-install"

# project repo data
ENV DMC_APP_PROJECT_DIR=/var/www/html
ENV DM_PROJECT_ENV=Development
ENV DM_REPOSITORY=''
ENV DM_REPO_BRANCH=master



### INSTALL SOFTWARE
ARG DMB_APP_PHP_VER=7.0
ARG DMB_APP_GITHUB_TOKEN
ARG COMPOSER_CONFIG_STRING=${DMB_APP_GITHUB_TOKEN:+"composer config -g github-oauth.github.com ${DMB_APP_GITHUB_TOKEN}"}
RUN apt-get -yqq update \
    && apt-get -yqq install software-properties-common \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get -yqq update \

    # apache, curl, zip, unzip, git
    && apt-get install -yqq --force-yes  --no-install-recommends apache2 curl zip unzip git \
    # ssh client for git
    && apt-get install -yqq openssh-client \
    # configure apache
    && ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/ \
    && sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \
    && mkdir -p /var/lock/apache2 /var/run/apache2 \

    # php
    && apt-get install -yqq --force-yes  --no-install-recommends php${DMB_APP_PHP_VER} libapache2-mod-php${DMB_APP_PHP_VER} \
        php${DMB_APP_PHP_VER}-mysql php${DMB_APP_PHP_VER}-mcrypt php${DMB_APP_PHP_VER}-mbstring \
        php${DMB_APP_PHP_VER}-xml php${DMB_APP_PHP_VER}-gd php${DMB_APP_PHP_VER}-intl \
        php${DMB_APP_PHP_VER}-soap php${DMB_APP_PHP_VER}-zip php${DMB_APP_PHP_VER}-curl \

    # DB client
    && apt-get install -yqq mariadb-client \

    # demonisation for docker
    && apt-get install -yqq supervisor && mkdir -p /var/log/supervisor \

    # composer
    && curl https://getcomposer.org/installer | php -- && mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer \
    # composer config if token exists
    && ${COMPOSER_CONFIG_STRING:-":"} \

    # mc, rsync and other utils
    && apt-get -yqq install mc rsync htop nano



### UPDATE & RUN PROJECT

EXPOSE 80

# copy files to install container
COPY install "${DMC_INSTALL_DIR}/"
RUN find "${DMC_INSTALL_DIR}" -type f -iname "*.sh" -exec chmod +x {} \;

# copy supervisord config file
COPY supervisord.conf /etc/supervisor/supervisord.conf

# copy and init run_once script
COPY run_once.sh /run_once.sh
ENV DMC_RUN_ONCE_FLAG="/run_once_flag"
RUN tee "${DMC_RUN_ONCE_FLAG}" && chmod +x /run_once.sh

# run custom run command if defined
ARG DMB_CUSTOM_BUILD_COMMAND
RUN ${DMB_CUSTOM_BUILD_COMMAND:-":"}



# clean temporary and unused folders and caches
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/mysql



# copy and init run script
COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]
