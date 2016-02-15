#!/bin/bash

if [ "${ENABLE_PROFILER}" = true ]; then
  echo "Enable profiler"
  cat << EOF | augtool -Ast "Trapperkeeper.lns incl /etc/puppetlabs/puppetserver/conf.d/*.conf"
defnode profiler /files/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf/@hash[.='profiler'] 'profiler'
defnode enabled \$profiler/@simple[.='enabled'] 'enabled'
set \$enabled/@value '${ENABLE_PROFILER}'
EOF
fi
