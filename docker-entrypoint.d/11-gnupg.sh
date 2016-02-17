#!/bin/bash

if test -n "${GPG_KEY}"; then
  echo "${GPG_KEY}" | gpg --import --homedir /opt/puppetlabs/server/data/puppetserver/.gnupg/
  chown -R puppet.puppet /opt/puppetlabs/server/data/puppetserver/.gnupg/
fi
