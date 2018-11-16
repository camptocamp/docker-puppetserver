#!/bin/bash

: ${GPG_KEYFILE:=/run/secrets/gpg.asc}

if test -f "${GPG_KEYFILE}"; then
  cat "${GPG_KEYFILE}" | gpg --import --homedir /opt/puppetlabs/server/data/puppetserver/.gnupg
  #chown -R puppet.puppet /opt/puppetlabs/server/data/puppetserver/.gnupg
fi
