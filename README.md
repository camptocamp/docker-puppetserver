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

### LOGBACK_APPENDER

You can override logback's logging appender using `LOGBACK_APPENDER` environment variable:

```shell
docker run --rm -e LOGBACK_APPENDER='<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender"><encoder class="net.logstash.logback.encoder.LogstashEncoder"><fieldNames><timestamp>timegenerated</timestamp><message>logmsg</message></fieldNames></encoder></appender>' camptocamp/puppetserver
```

### REQUEST_LOGGING_APPENDER

You can override request-logging's encoder class using `REQUEST_LOGGING_APPENDER` environment variable:

```shell
docker run --rm -e REQUEST_LOGGING_APPENDER='<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender"><encoder class="net.logstash.logback.encoder.AccessEventCompositeJsonEncoder"><providers><version/><pattern><pattern>{"timegenerated":"%date{yyyy-MM-dd'T'HH:mm:ss.SSSXXX}","clientip":"%remoteIP","auth":"%user","verb":"%requestMethod","requestprotocol":"%protocol","rawrequest":"%requestURL","response":"#asLong{%statusCode}","bytes":"#asLong{%bytesSent}","total_service_time":"#asLong{%elapsedTime}","request":"http://%header{Host}%requestURI","referrer":"%header{Referer}","agent":"%header{User-agent}","request.host":"%header{Host}","request.accept":"%header{Accept}","request.accept-encoding":"%header{Accept-Encoding}","request.connection":"%header{Connection}","puppet.client-verify":"%header{X-Client-Verify}","puppet.client-dn":"%header{X-Client-DN}","puppet.client-cert":"%header{X-Client-Cert}","response.content-type":"%responseHeader{Content-Type}","response.content-length":"%responseHeader{Content-Length}","response.server":"%responseHeader{Server}","response.connection":"%responseHeader{Connection}"}</pattern></pattern></providers></encoder></appender>' camptocamp/puppetserver
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
