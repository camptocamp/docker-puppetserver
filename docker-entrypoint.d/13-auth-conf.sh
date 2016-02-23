#!/bin/bash

if test -n "${AUTH_CONF_ALLOW_CATALOG}"; then
  cat << EOF | augtool -Ast "Puppet_Auth.lns incl /etc/puppetlabs/puppet/auth.conf"
defvar noentry /files/etc/puppetlabs/puppet/auth.conf/path[.=~regexp('.*/catalog/.*') and count(allow/*[.='${AUTH_CONF_ALLOW_CATALOG}'])=0]
set \$noentry/allow/01 '${AUTH_CONF_ALLOW_CATALOG}'
EOF
fi
