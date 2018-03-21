# 3.2.0 (2018-03-21)

- small fixes


# 3.0.0 (2018-03-21)

- add default `root` user password
- add special `dm` user to make `docker exec` under no-root user by default
- add colored term prompt
- DM* prefixed and renamed


# 2.0.1 (2018-03-05)

- add nano util to default installation


# 2.0 (2017-11-30)

- add CHANGELOG.md :)
- refactor structure of image source folder, add version of image format, add new format version
- split run and run_once scripts on base and custom one
- remove apache dummy from image, add dummy customization possibility
- add rsync, zip etc. utils to all apps' containers
- fix Moodle image: replace related sitename into fixed - for cron jobs
- fix cron service start at app containers
- add new app apache-php-based container with refactored structure
- add new app apache-Moodle-based container with refactored structure
- add new app apache-Yii2-based container with refactored structure
- move docker images to separate repository
- add tags
- push to [DockerHub](https://hub.docker.com/r/demmonico/ubuntu-apache-php/)


# 1.1

- First release
