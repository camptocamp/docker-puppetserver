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

### EXTERNAL_SSL_TERMINATION

If you set `EXTERNAL_SSL_TERMINATION` to `true`, puppetserver will listen on `8080` in HTTP so that you can use an external SSL termination according to this doc : https://docs.puppetlabs.com/puppetserver/latest/external_ssl_termination.html.

### MAX_ACTIVE_INSTANCES

You can tune `max-active-instances` using the `MAX_ACTIVE_INSTANCES` environment variable.

### ENABLE_PROFILER

You can enable the profiler using the `ENABLE_PROFILER` environment variable.

Linking auto configuration:
---------------------------

### puppetdb-termini

If the container can resolve `puppetdb`, puppetdb-termini will be enabled.

### riemann

If the container can resolve `riemann`, the riemann reporter will be enabled (https://github.com/jamtur01/puppet-riemann).

### graphite

If the container can resolve `graphite`, the graphite reporter will be enabled (https://github.com/evenup/evenup-graphite_reporter).
