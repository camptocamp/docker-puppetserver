#!/bin/sh

echo "${AUTOSIGN_PSK}" > /opt/puppetlabs/server/data/puppetserver/autosign_psk
chmod 0660 /opt/puppetlabs/server/data/puppetserver/autosign_psk
