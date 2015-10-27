#!/bin/bash

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

if getent hosts puppetdb > /dev/null 2>&1 ; then
  echo "Configure puppetdb-termini"
  puppet config set storeconfigs true --section master
  puppet config set storeconfigs_backend puppetdb --section master
  puppet config set reports puppetdb --section master
  cat << EOF > $(puppet config print route_file)
---
master:
  facts:
    terminus: puppetdb
    cache: yaml
EOF
fi

puppetserver foreground
