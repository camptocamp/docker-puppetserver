#!/bin/bash

if [[ ! -z "${MAX_ACTIVE_INSTANCES}" && "${MAX_ACTIVE_INSTANCES}" -ge 1 ]]; then
  echo "Setting maximum number of JRuby instances to allow to ${MAX_ACTIVE_INSTANCES}"
  cat << EOF | augtool -Ast "Trapperkeeper.lns incl /etc/puppetlabs/puppetserver/conf.d/*.conf"
defnode jruby /files/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf/@hash[.='jruby-puppet'] 'jruby-puppet'
defnode max \$jruby/@simple[.='max-active-instances'] 'max-active-instances'
set \$max/@value '${MAX_ACTIVE_INSTANCES}'
EOF
fi
