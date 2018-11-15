#!/bin/bash

CA_DIR=$(puppet config print cadir)

: ${CA_KEY:=/run/secrets/ca_key.pem}
: ${CA_CRT:=/run/secrets/ca_crt.pem}
: ${CA_CRL:=/run/secrets/ca_crl.pem}

if [ ! -e "${CA_DIR}/inventory.txt" ]; then
  echo "Importing CA"
  puppetserver ca import --private-key "${CA_KEY}" \
	                     --cert-bundle "${CA_CRT}" \
						 --crl-chain "${CA_CRL}"
  chmod -R g=u ${CA_DIR}/*
else
  echo "CA is already imported. Clear it if you need to import again."
fi
