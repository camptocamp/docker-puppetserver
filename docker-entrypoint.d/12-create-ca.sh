#!/bin/bash

if [ ! -e /etc/puppetlabs/puppet/ssl/ca/inventory.txt ]; then
  echo "Importing CA"
  puppetserver ca import --private-key /ca_key.pem --cert-bundle /ca_crt.pem --crl-chain /ca_crl.pem
  chmod g=u /etc/puppetlabs/puppet/ssl/ca/*
else
  echo "CA is already imported. Clear it if you need to import again."
fi
