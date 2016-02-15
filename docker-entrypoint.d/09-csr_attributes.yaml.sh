#!/bin/bash

if getent hosts rancher-metadata > /dev/null; then
  # Generate csr_attributes.yaml
  cat << EOF > /etc/puppetlabs/puppet/csr_attributes.yaml
---
custom_attributes:
  1.2.840.113549.1.9.7: '$(curl http://rancher-metadata/latest/self/service/name 2> /dev/null):$(curl http://rancher-metadata/latest/self/service/uuid 2> /dev/null)'
EOF

  # Get certificate
  if getent hosts puppetca > /dev/null; then
    puppet agent -t --noop --server puppetca
  else
    puppet agent -t --noop
  fi
fi
