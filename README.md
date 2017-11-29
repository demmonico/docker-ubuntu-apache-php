# Docker PHP-based image

## Description

Docker PHP-based image. Use as image for application container.


## Installs

- Ubuntu 14.04
- Apache 2.4 with mod_rewrite enabled
- curl, zip, unzip, git
- openssh-client
- PHP (see version in image tag)
- PHP extensions/libs (mysql, xml, gd, mcrypt, mbstring, soap, intl, zip, curl)
- mariadb-client
- supervisor
- composer
- mc, rsync, htop


## Build arguments

- PHP_VER (default 7.0)
- GITHUB_TOKEN (if defined then composer will be configured due this token)
- CUSTOM_BUILD_COMMAND (will run if defined in the end of build)


## Environment variables

- DUMMY_DIR
- INSTALL_DIR
- PROJECT_DIR
- PROJECT_ENV
- REPOSITORY
- REPO_BRANCH


## Build

```sh
docker build -t demmonico/ubuntu-apache-php --build-arg PHP_VER=7.0 --no-cache .
```

## Make tag

```sh
docker tag IMAGE_ID demmonico/ubuntu-apache-php:7.0
```

## Push image to Docker Hub

```sh
docker push demmonico/ubuntu-apache-php
```
or with tag
```sh
docker push demmonico/ubuntu-apache-php:7.0
```

## Change log

See the [CHANGELOG](CHANGELOG.md) file for change logs.
