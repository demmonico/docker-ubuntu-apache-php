# Dockerfile for build app container
#
# tech-stack: ubuntu / apache / php
#
# @author demmonico
# @image ubuntu-apache-php
# @version v2.0


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
ENV DUMMY_DIR="/docker-dummy"

# additional files required to run container (from version v2.0)
ENV INSTALL_DIR="/docker-install"

# project repo data
ENV PROJECT_DIR=/var/www/html
ENV PROJECT_ENV=Development
ENV REPOSITORY=''
ENV REPO_BRANCH=master



### INSTALL SOFTWARE
ARG PHP_VER=7.0
ARG GITHUB_TOKEN
ARG COMPOSER_CONFIG_STRING=${GITHUB_TOKEN:+"composer config -g github-oauth.github.com ${GITHUB_TOKEN}"}
RUN apt-get update \
    && apt-get -y install software-properties-common \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update \

    # apache, curl, zip, unzip, git
    && apt-get install -y --force-yes  --no-install-recommends apache2 curl zip unzip git \
    # ssh client for git
    && apt-get install -y openssh-client \
    # configure apache
    && ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/ \
    && sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \

    # php
    && apt-get install -y --force-yes  --no-install-recommends php${PHP_VER} libapache2-mod-php${PHP_VER} \
        php${PHP_VER}-mysql php${PHP_VER}-xml php${PHP_VER}-gd php${PHP_VER}-mcrypt php${PHP_VER}-mbstring php${PHP_VER}-soap php${PHP_VER}-intl php${PHP_VER}-zip php${PHP_VER}-curl \

    # DB client
    && apt-get install -y mariadb-client \

    # demonisation for docker
    && apt-get install -y supervisor \

    # composer
    && curl https://getcomposer.org/installer | php -- && mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer \
    # composer config if token exists
    && ${COMPOSER_CONFIG_STRING:-":"} \

    # mc, rsync and other utils
    && apt-get -qq update && apt-get -qq -y install mc rsync htop \

    # clear apt etc
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/mysql \
    && mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor


EXPOSE 80


### UPDATE & RUN PROJECT

# copy supervisord config file
COPY supervisord.conf /etc/supervisor/supervisord.conf

# copy and init run_once script
COPY run_once.sh /run_once.sh
ENV RUN_ONCE_FLAG="/run_once_flag"
RUN tee "${RUN_ONCE_FLAG}" && chmod +x /run_once.sh

# run custom run command if defined
ARG CUSTOM_BUILD_COMMAND
RUN ${CUSTOM_BUILD_COMMAND:-":"}

# copy and init run script
COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]
