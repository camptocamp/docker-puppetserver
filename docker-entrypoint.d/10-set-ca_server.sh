#!/bin/bash

if test -n "${CA}" && ! $CA; then
  puppet config set ca_server puppetca --section main
  sed -i -e 's@^\(puppetlabs.services.ca.certificate-authority-service/certificate-authority-service\)@# \1@' -e 's@.*\(puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service\)@\1@' /etc/puppetlabs/puppetserver/bootstrap.cfg
fi
