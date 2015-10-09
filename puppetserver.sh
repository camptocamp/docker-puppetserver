#!/bin/bash

if [ "${EXTERNAL_SSL_TERMINATION}" ]; then
  echo "Configuring Puppet server for External SSL Termination"
  # TODO: use augeas
  sed -i -e '/ssl-port/i \    port = 8080' -e '/ssl-host/i \    host = 0.0.0.0' /etc/puppetlabs/puppetserver/conf.d/webserver.conf
  echo -e "master: {\n    allow-header-cert-info: true\n}" > /etc/puppetlabs/puppetserver/conf.d/master.conf
fi

if [ "${MAX_ACTIVE_INSTANCES}" ]; then
  echo "Setting maximum number of JRuby instances to allow to ${MAX_ACTIVE_INSTANCE}"
  # TODO: use augeas
  sed -i -E "s/^#?max-active-instances: .*$/max-active-instances: ${MAX_ACTIVE_INSTANCES}/" /etc/puppetlabs/puppetserver/conf.d/puppetserver.conf
fi

puppetserver foreground
