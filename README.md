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
docker run --rm -e JAVA_ARGS='-Xmx4G' camptocamp/puppetserver
```


### Secrets

This image expects the following secrets:

  - ca_key.pem: the CA private key
  - ca_cert.pem: the CA cert bundle
  - ca_crl.pem: the CA CRL
  - gpg.asc: the GPG key (for hiera-eyaml-gpg)
  - autosign_psk: the PSK for autosign policy


Linking auto configuration:
---------------------------

### puppetdb-termini

If the container can resolve `puppetdb`, puppetdb-termini will be enabled.
