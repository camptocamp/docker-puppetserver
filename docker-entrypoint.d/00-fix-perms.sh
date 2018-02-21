#!/bin/bash

# Fix volumes ownership
chown -R puppet:puppet /etc/puppetlabs/puppet/ssl
chown puppet:puppet /etc/puppetlabs/code/environments
