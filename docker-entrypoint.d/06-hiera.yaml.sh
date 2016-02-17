#!/bin/bash

if test -n "${HIERA_YAML}"; then
  echo -e "${HIERA_YAML}" > /etc/puppetlabs/code/hiera.yaml
fi
