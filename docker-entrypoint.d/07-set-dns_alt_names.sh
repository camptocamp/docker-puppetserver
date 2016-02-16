#!/bin/bash

if test -n "${DNS_ALT_NAMES}"; then
  echo "Configure dns_alt_names"
  puppet config set dns_alt_names $DNS_ALT_NAMES --section agent
fi
