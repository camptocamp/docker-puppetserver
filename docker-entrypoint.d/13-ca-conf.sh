#!/bin/bash

if test -n "${CA_WHITELIST}"; then
    cat << EOF > /etc/puppetlabs/puppetserver/conf.d/ca.conf
certificate-authority: {
   certificate-status: {
       authorization-required: true
       client-whitelist: [${CA_WHITELIST}]
   }
}
EOF
fi
