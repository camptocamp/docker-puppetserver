#!/bin/bash

# Wait 3 second to give time to Docker to update /etc/resolv.conf
sleep 3

if [ "${EXTERNAL_SSL_TERMINATION}" = true ]; then
  echo "Configuring Puppet server for External SSL Termination"
  cat << 'EOF' | augtool -Ast "Trapperkeeper.lns incl /etc/puppetlabs/puppetserver/conf.d/*.conf"
defnode webserver /files/etc/puppetlabs/puppetserver/conf.d/webserver.conf/@hash[.='webserver'] webserver
defnode host $webserver/@simple[.='host'] host
set $host/@value '0.0.0.0'
defnode port $webserver/@simple[.='port'] port
set $port/@value '8080'

defnode master /files/etc/puppetlabs/puppetserver/conf.d/master.conf/@hash[.='master'] master
defnode allow $master/@simple[.='allow-header-cert-info'] 'allow-header-cert-info'
set $allow/@value true
EOF
fi

if [[ ! -z "${MAX_ACTIVE_INSTANCES}" && "${MAX_ACTIVE_INSTANCES}" -ge 1 ]]; then
  echo "Setting maximum number of JRuby instances to allow to ${MAX_ACTIVE_INSTANCES}"
  cat << EOF | augtool -Ast "Trapperkeeper.lns incl /etc/puppetlabs/puppetserver/conf.d/*.conf"
defnode jruby /files/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf/@hash[.='jruby-puppet'] 'jruby-puppet'
defnode max \$jruby/@simple[.='max-active-instances'] 'max-active-instances'
set \$max/@value '${MAX_ACTIVE_INSTANCES}'
EOF
fi

if [ "${ENABLE_PROFILER}" = true ]; then
  echo "Enable profiler"
  cat << EOF | augtool -Ast "Trapperkeeper.lns incl /etc/puppetlabs/puppetserver/conf.d/*.conf"
defnode profiler /files/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf/@hash[.='profiler'] 'profiler'
defnode enabled \$profiler/@simple[.='enabled'] 'enabled'
set \$enabled/@value '${ENABLE_PROFILER}'
EOF
fi

reports=''

if test -n "${CERTNAME}"; then
  echo "Configure certname"
  puppet config set certname $CERTNAME --section agent
fi

if getent hosts puppetdb > /dev/null 2>&1 ; then
  echo "Generating puppetdb certificate"
  puppet cert generate puppetdb

  echo "Configure puppetdb-termini"
  puppet config set storeconfigs true --section master
  puppet config set storeconfigs_backend puppetdb --section master
  test -n "${reports}" && reports="${reports},puppetdb" || reports="puppetdb"
  cat << EOF > $(puppet config print route_file)
---
master:
  facts:
    terminus: puppetdb
    cache: yaml
EOF
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

# Fix volumes ownership
chown puppet:puppet /etc/puppetlabs/puppet/ssl

exec puppetserver foreground $@
