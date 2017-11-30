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
