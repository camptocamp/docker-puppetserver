#!/bin/bash

mkdir -p /etc/puppetlabs/puppet/ssl/ca

if test -n "${CA_KEY}"; then
  echo "${CA_KEY}" > /etc/puppetlabs/puppet/ssl/ca/ca_key.pem
  chmod 0640 /etc/puppetlabs/puppet/ssl/ca/ca_key.pem
fi

if test -n "${CA_CRT}"; then
  echo "${CA_CRT}" > /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem
  chmod 0644 /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem
fi

chown -R puppet.puppet /etc/puppetlabs/puppet/ssl/ca
