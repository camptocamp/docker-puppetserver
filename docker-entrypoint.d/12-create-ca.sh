#!/bin/bash

if test -n "${CA_KEY}" && test -n "${CA_CRT}"; then
  mkdir -p /etc/puppetlabs/puppet/ssl/ca

  echo "${CA_KEY}" > /etc/puppetlabs/puppet/ssl/ca/ca_key.pem
  chmod 0640 /etc/puppetlabs/puppet/ssl/ca/ca_key.pem
  echo "${CA_CRT}" > /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem
  chmod 0644 /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem
  puppet cert generate foobar
  puppet cert clean foobar

  chown -R puppet.puppet /etc/puppetlabs/puppet/ssl/ca
fi
