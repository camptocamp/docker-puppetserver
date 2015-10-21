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

if [ "${METRICS}" = true ]; then
  echo "Configuring Puppetserver metrics"
  cat << EOF > /etc/puppetlabs/puppetserver/conf.d/metrics.conf
# metrics-related settings
metrics: {
    # enable or disable the metrics system
    enabled: true

    # a server id that will be used as part of the namespace for metrics produced
    # by this server
    server-id: ${SERVER_ID:-HOSTNAME}

    # this section is used to configure reporters that will send the metrics
    # to various destinations for external viewing
    reporters: {

        # enable or disable JMX metrics reporter
        jmx: {
            enabled: true
        }

        # enable or disable graphite metrics reporter
        graphite: {
            enabled: true

            # graphite host
            host: "graphite"
            # graphite metrics port
            port: 2003
            # how often to send metrics to graphite
            update-interval-seconds: 5
        }
    }
}
EOF
fi

puppetserver foreground
