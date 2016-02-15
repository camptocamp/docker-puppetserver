#!/bin/bash

reports=''

if test -n "${CA}" && ! $CA && getent hosts puppetdb > /dev/null 2>&1 ; then
  echo "Configure report to puppetdb"
  test -n "${reports}" && reports="${reports},puppetdb" || reports="puppetdb"
fi

if getent hosts riemann > /dev/null 2>&1 ; then
  echo "Configure report to riemann"
  test -n "${reports}" && reports="${reports},riemann" || reports="riemann"
  cat << EOF > $(puppet config print confdir)/riemann.yaml
---
:riemann_server: 'riemann'
:riemann_port: 5555
EOF
fi

if getent hosts graphite > /dev/null 2>&1 ; then
  echo "Configure report to graphite"
  test -n "${reports}" && reports="${reports},graphite" || reports="graphite"
  cat << EOF > $(puppet config print confdir)/graphite.yaml
---
:graphite_server: 'graphite'
:graphite_port: 2003
EOF
fi

echo "reports=${reports}"
test -n "${reports}" && puppet config set reports $reports --section master

exit 0
