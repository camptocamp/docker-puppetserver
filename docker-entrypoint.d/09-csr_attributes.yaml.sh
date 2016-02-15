#!/bin/bash

if getent hosts rancher-metadata; then
  echo $(curl http://rancher-metadata/latest/self/service/name 2> /dev/null):$(curl http://rancher-metadata/latest/self/service/uuid 2> /dev/null) > /etc/puppetlabs/puppet/csr_attributes.yaml
fi
