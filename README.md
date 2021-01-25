*Docker PHP base image. Built with presets and common tools for WordPress and Laravel*

There are many Docker imagages for PHP out there with various configurations, tooling, and performance. Many of them are overly bloated or do not have the commonly used libraries by frameworks such as WordPress and Laravel. This image aims to bridge that gap.

Additionally, this flavor is running the Apache webserver.

## Environment Variables

There are a few environment variables available that provide some customization:

* NEW_RELIC_LICENSE_KEY - NewRelic APM key
* NEW_RELIC_APP_NAME - Customizable NewRelic App name. Also reports to All Apps

## Available PHP Libraries

The following PHP libraries are available inside this image:

* bcmath
* bz2
* calendar
* exif
* gd
* intl
* ldap
* memcached
* mysqli
* opcache
* pcntl
* pdo_mysql
* pdo_pgsql
* redis
* soap
* xsl
* zip
* imagick

## System Tools

To ease administration, a few tools have been made available inside the container:

* NewRelic APM
* wget
* composer
* nvm
* wp-cli