# Docker PHP-based image

## Description

Docker PHP-based image. Use as image for application container.
Was developed for using with [Docker Manager](https://github.com/demmonico/docker-manager/). 
But could be used separately.
You could pull image from here and build locally either pull from [Docker Hub](https://hub.docker.com/r/demmonico/ubuntu-apache-php/) directly.


### Installs

- Ubuntu 14.04
- Apache 2.4 with mod_rewrite enabled
- curl, zip, unzip, git
- openssh-client
- PHP (see version in image tag)
- PHP extensions/libs (mysql, xml, gd, mcrypt, mbstring, soap, intl, zip, curl)
- mariadb-client
- supervisor
- composer
- mc, rsync, htop, nano


### Build arguments

- DMB_APP_PHP_VER (default 7.0)
- DMB_APP_GITHUB_TOKEN (if defined then composer will be configured due this token)
- DMB_CUSTOM_BUILD_COMMAND (will run if defined in the end of build)


### Environment variables

- DM_PROJECT_ENV
- DM_REPOSITORY
- DM_REPO_BRANCH
- DMC_APP_APACHE_DUMMY_DIR (on `run`, if dir exists)
- DMC_INSTALL_DIR
- DMC_APP_PROJECT_DIR (on `run`)
- DMC_ROOT_PASSWD (on `run_once`)
- DMC_DM_USER  (on `run_once`)
- DMC_DM_PASSWD  (on `run_once`)
- DMC_APP_APACHE_UPLOADMAXFILESIZE
- DMC_APP_APACHE_POSTMAXSIZE
- DMC_APP_APACHE_MEMORYLIMIT
- DMC_APP_APACHE_MAXEXECTIME
- DMC_APP_APACHE_MAXINPUTTIME
- DMC_CUSTOM_RUN_COMMAND
- DMC_CUSTOM_RUNONCE_COMMAND
- DMC_EXEC_NAME (pass container's name while `exec` cmd)
- DMC_CUSTOM_ADD_HOSTS (updating /etc/hosts; format `container:domain` or `IP:domain`; allow multiple separated by `;`)


## Build && push

### Build

Build image with default PHP version
```sh
docker build -t demmonico/ubuntu-apache-php --no-cache .
```
or build image with PHP version specified.
```sh
docker build -t demmonico/ubuntu-apache-php --build-arg DMB_APP_PHP_VER=7.0 --no-cache .
```

### Make tag

```sh
docker tag IMAGE_ID demmonico/ubuntu-apache-php:7.0
```

### Push image to Docker Hub

```sh
docker push demmonico/ubuntu-apache-php
```
or with tag
```sh
docker push demmonico/ubuntu-apache-php:7.0
```


## Usage

### Dockerfile

```sh
FROM demmonico/ubuntu-apache-php:7.0
  
# optional copy files to install container
COPY install "${DMC_INSTALL_DIR}/"
  
CMD ["/run.sh"]
```

### Docker Compose

```sh
...
image: demmonico/ubuntu-apache-php
# or
build: local_path_to_dockerfile
  
environment:
  # optional - define environment's name
  - DM_PROJECT_ENV=Development
  # optional - add link to internal domain to the /etc/hosts file for container named dm000main_app_1
  # recommended
  - DMC_CUSTOM_ADD_HOSTS=container_name:example.com
  # or
  - DMC_CUSTOM_ADD_HOSTS=172.19.0.3:example.com
  # or alternatively (common exec custom command)
  - DMC_CUSTOM_RUN_COMMAND=bash -c `echo "$$( getent hosts container_name | awk '{ print $$1 }' ) example.com" >> /etc/hosts`
  
volumes:
  # webapp code
  - ./app/src:/var/www/html
  
env_file:
  # provides values for ENV variables VIRTUAL_HOST, DM_PROJECT, DM_HOST_USER_NAME, DM_HOST_USER_ID
  - host.env
...
```


## Change log

See the [CHANGELOG](CHANGELOG.md) file for change logs.
