#!/bin/bash

if test -n "${CA}" && ! $CA; then
  puppet config set ca_server puppetca --section main
  certname=$(puppet config print certname)
  sed -i -e 's@^\(puppetlabs.services.ca.certificate-authority-service/certificate-authority-service\)@# \1@' -e 's@.*\(puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service\)@\1@' /etc/puppetlabs/puppetserver/services.d/ca.cfg
  cat << EOF | augtool -Ast "Trapperkeeper.lns incl /etc/puppetlabs/puppetserver/conf.d/webserver.conf"
defnode webserver /files/etc/puppetlabs/puppetserver/conf.d/webserver.conf/@hash[.='webserver'] webserver
defnode sslcert \$webserver/@simple[.='ssl-cert'] ssl-cert
set \$sslcert/@value '/etc/puppetlabs/puppet/ssl/certs/${certname}.pem'
defnode sslkey \$webserver/@simple[.='ssl-key'] ssl-key
set \$sslkey/@value '/etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem'
defnode sslcacert \$webserver/@simple[.='ssl-ca-cert'] ssl-ca-cert
set \$sslcacert/@value '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
defnode sslcrlpath \$webserver/@simple[.='ssl-crl-path'] ssl-crl-path
set \$sslcrlpath/@value '/etc/puppetlabs/puppet/ssl/crl.pem'
EOF
fi
