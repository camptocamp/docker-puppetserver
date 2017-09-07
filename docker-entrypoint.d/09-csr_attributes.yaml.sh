#!/bin/bash

if getent hosts rancher-metadata > /dev/null && test -n "${CA}" && ! ${CA} ; then
  # Generate csr_attributes.yaml
  cat << EOF > /etc/puppetlabs/puppet/csr_attributes.yaml
---
custom_attributes:
  1.2.840.113549.1.9.7: '$(curl http://rancher-metadata/latest/self/service/name 2> /dev/null):$(curl http://rancher-metadata/latest/self/service/uuid 2> /dev/null)'
EOF

  # Get certificate
  rc=1
  while test $rc -ne 0; do
    if getent hosts puppetca > /dev/null; then
      puppet agent -t --noop --server puppetca
    else
      puppet agent -t --noop
    fi
    rc=$?
  done
elif test -n "${AUTOSIGN_PSK}"; then
  # Generate csr_attributes.yaml
  cat << EOF > /etc/puppetlabs/puppet/csr_attributes.yaml
---
custom_attributes:
  1.2.840.113549.1.9.7: 'hashed;$(CERTNAME=$(puppet config print certname) ruby -e 'require "openssl"; print Digest::SHA256.base64digest(ENV["AUTOSIGN_PSK"] + "/" + ENV["CERTNAME"] + "/puppet/production")')'
extension_requests:
  pp_role: puppet
  pp_environment: production
EOF

  # Get certificate
  rc=1
  while test $rc -ne 0; do
    if getent hosts puppetca > /dev/null; then
      puppet agent -t --noop --server puppetca
    else
      puppet agent -t --noop
    fi
    rc=$?
  done
fi
