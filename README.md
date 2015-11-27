Puppetserver Docker image
==========================

[![Docker Pulls](https://img.shields.io/docker/pulls/camptocamp/puppetserver.svg)](https://hub.docker.com/r/camptocamp/puppetserver/)
[![Build Status](https://img.shields.io/travis/camptocamp/docker-puppetserver/master.svg)](https://travis-ci.org/camptocamp/docker-puppetserver)
[![By Camptocamp](https://img.shields.io/badge/by-camptocamp-fb7047.svg)](http://www.camptocamp.com)

Available environment variables:
--------------------------------

### JAVA_ARGS

You can set `JAVA_ARGS` using a Docker environment variables:

```shell
docker run --rm -e JAVA_ARGS='-Xmx 4G' camptocamp/puppetserver
```

#### Configure Log Appender

##### STDOUT appender

The default log appender in `STDOUT` so that you can see the output using `docker-compose logs` for example.

##### FILE appender

You can add `-Dlogappender=FILE` to `JAVA_ARGS` so that it outputs in `/var/log/puppetlabs/puppetserver/puppetserver.log` and `/var/log/puppetlabs/puppetserver/puppetserver-access.log`.

##### LOGSTASH appender

You can add `-Dlogappender=LOGSTASH` to `JAVA_ARGS` so that it outputs in `/var/log/puppetlabs/puppetserver/puppetserver.log.json` and `/var/log/puppetlabs/puppetserver/puppetserver-access.log.json` using `net.logstash.logback.encoder`.
