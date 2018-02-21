#!/bin/sh

echo "${AUTOSIGN_PSK}" > /etc/puppetlabs/puppet/autosign_psk
chown root:puppet /etc/puppetlabs/puppet/autosign_psk
chmod 0660 /etc/puppetlabs/puppet/autosign_psk
