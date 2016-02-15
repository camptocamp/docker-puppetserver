#!/bin/bash

if test -n "${CA}" && ! ${CA} && getent hosts puppetdb > /dev/null 2>&1 ; then
  echo "Configure puppetdb-termini"
  puppet config set storeconfigs true --section master
  puppet config set storeconfigs_backend puppetdb --section master
  cat << EOF > $(puppet config print route_file)
---
master:
  facts:
    terminus: puppetdb
    cache: yaml
EOF
fi
